/**
 * Enhanced Status Bar Extension
 *
 * Replaces the default footer with a richer status line:
 *   left:  ● model · ⎇ branch          (● = idle/streaming indicator)
 *   right: ↑input ↓output $cost · %ctx · #turn · ●level · turn_dur
 *
 * Toggle with /status-bar command.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

export default function (pi: ExtensionAPI) {
	let enabled = true;
	let turnCount = 0;
	let currentModel = "";
	let currentThinkingLevel = "";
	let isIdle = true;
	let requestRender: (() => void) | null = null;
	let turnStartTime: number | null = null;
	let lastTurnDuration = "";

	const fmt = (n: number): string => {
		if (n < 1_000) return `${n}`;
		if (n < 1_000_000) return `${(n / 1_000).toFixed(1)}k`;
		return `${(n / 1_000_000).toFixed(1)}m`;
	};

	const formatDuration = (ms: number): string => {
		const s = Math.floor(ms / 1000);
		if (s < 60) return `${s}s`;
		const m = Math.floor(s / 60);
		if (m < 60) return `${m}m${s % 60}s`;
		const h = Math.floor(m / 60);
		return `${h}h${String(m % 60).padStart(2, "0")}m`;
	};

	const thinkingLabel = (level: string): string => {
		const map: Record<string, string> = {
			off: "off",
			minimal: "min",
			low: "low",
			medium: "med",
			high: "high",
			xhigh: "xhi",
		};
		return map[level] ?? level.slice(0, 3);
	};

	function applyFooter(ctx: any) {
		if (!ctx.hasUI) return;
		ctx.ui.setFooter((tui: any, theme: any, footerData: any) => {
			requestRender = () => tui.requestRender();
			const unsubBranch = footerData.onBranchChange(() => tui.requestRender());
			const unsubStatus = footerData.onStatusChange?.() ?? (() => {});

			return {
				dispose() {
					requestRender = null;
					unsubBranch();
					unsubStatus();
				},
				invalidate() {},
				render(width: number): string[] {
					let input = 0;
					let output = 0;
					let cost = 0;
					for (const e of ctx.sessionManager.getBranch()) {
						if (e.type === "message" && e.message.role === "assistant") {
							const m = e.message as AssistantMessage;
							input += m.usage?.input ?? 0;
							output += m.usage?.output ?? 0;
							cost += m.usage?.cost?.total ?? 0;
						}
					}

					const branch = footerData.getGitBranch() || "";
					const extStatuses = footerData.getExtensionStatuses();

					// Left: idle dot · model · branch
					const idleDot = theme.fg(isIdle ? "success" : "warning", "●");
					const modelTag = currentModel
						? theme.bg("selectedBg", theme.fg("accent", currentModel))
						: theme.fg("dim", "no model");
					const branchTag = branch
						? theme.fg("muted", `⎇ ${branch}`)
						: "";
					const left = [idleDot, modelTag, branchTag]
						.filter(Boolean)
						.join(theme.fg("dim", " · "));

					// Right: tokens · cost · ctx% · turn · thinking · statuses
					const tokens = theme.fg("dim", `↑${fmt(input)} ↓${fmt(output)}`);
					const costStr = theme.fg("success", `$${cost.toFixed(4)}`);

					const ctxUsage = ctx.getContextUsage?.();
					const ctxPct = ctxUsage?.percent;
					const ctxStr = ctxPct != null
						? ctxPct > 90
							? theme.bg("toolErrorBg", theme.fg("warning", `${Math.round(ctxPct)}%`))
							: theme.fg(ctxPct > 75 ? "muted" : "dim", `${Math.round(ctxPct)}%`)
						: "";

					const turnStr = theme.bg("customMessageBg", theme.fg("accent", ` #${turnCount} `));

					const tlStr = currentThinkingLevel
						? theme.bg("toolPendingBg", theme.fg("borderAccent", `● ${thinkingLabel(currentThinkingLevel)}`))
						: "";

					const durStr = turnStartTime != null
						? theme.fg("dim", formatDuration(Date.now() - turnStartTime))
						: lastTurnDuration
							? theme.fg("dim", lastTurnDuration)
							: "";

					const rightParts = [tokens, costStr];
					if (ctxStr) rightParts.push(ctxStr);
					rightParts.push(turnStr);
					if (tlStr) rightParts.push(tlStr);
					if (durStr) rightParts.push(durStr);

					if (extStatuses && Object.keys(extStatuses).length > 0) {
						const statusText = Object.values(extStatuses)
							.filter(Boolean)
							.join(" ");
						if (statusText) rightParts.push(theme.fg("muted", statusText));
					}
					const right = rightParts.join(theme.fg("dim", " · "));

					const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
					return [truncateToWidth(left + pad + right, width)];
				},
			};
		});
	}

	pi.on("session_start", (_event, ctx) => {
		currentModel = ctx.model?.id ?? "";
		currentThinkingLevel = pi.getThinkingLevel?.() ?? "";
		turnCount = 0;
		isIdle = true;
		if (enabled) applyFooter(ctx);
	});

	pi.on("model_select", (event, ctx) => {
		currentModel = event.model.id;
		if (enabled) applyFooter(ctx);
	});

	pi.on("thinking_level_select", (event) => {
		currentThinkingLevel = event.level;
		requestRender?.();
	});

	pi.on("agent_start", () => {
		isIdle = false;
		requestRender?.();
	});

	pi.on("agent_settled", () => {
		isIdle = true;
		requestRender?.();
	});

	pi.on("turn_start", (event) => {
		turnCount++;
		turnStartTime = event.timestamp;
		lastTurnDuration = "";
	});

	pi.on("turn_end", () => {
		if (turnStartTime != null) {
			lastTurnDuration = formatDuration(Date.now() - turnStartTime);
			turnStartTime = null;
		}
	});

	pi.on("session_shutdown", (_event, ctx) => {
		if (ctx.hasUI) ctx.ui.setFooter(undefined);
	});

	pi.registerCommand("status-bar", {
		description:
			"Toggle enhanced status bar (model, git branch, tokens, cost, turn count, context %, thinking level, idle indicator)",
		handler: async (_args, ctx) => {
			enabled = !enabled;
			if (enabled) {
				applyFooter(ctx);
				ctx.ui.notify("Enhanced status bar enabled", "info");
			} else {
				ctx.ui.setFooter(undefined);
				ctx.ui.notify("Default status bar restored", "info");
			}
		},
	});
}
