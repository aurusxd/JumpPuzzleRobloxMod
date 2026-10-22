--!strict
-- client/ui/screens/ProgressHud.luau
-- Minimal HUD showing current stage progress (S0-8 reference vertical)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local Label = require(script.Parent.Parent.primitives.Label)
local ProgressBar = require(script.Parent.Parent.primitives.ProgressBar)
local Panel = require(script.Parent.Parent.primitives.Panel)

local TOTAL_STAGES = 30 -- from tech.md §1: ~30 stages

export type ProgressHudProps = {
	stageId: string,
	highestStage: number,
}

local function ProgressHud(props: ProgressHudProps)
	local progress = props.highestStage / TOTAL_STAGES

	return React.createElement(Panel, {
		size = UDim2.new(0, 280, 0, 80),
		position = UDim2.new(0, 16, 0, 16),
		anchorPoint = Vector2.new(0, 0),
		transparency = 0.3,
		children = {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
			}),
			StageLabel = React.createElement(Label, {
				text = if props.stageId ~= "" then `Stage: {props.stageId}` else "Start running!",
				textSize = 14,
				font = Enum.Font.GothamBold,
				layoutOrder = 1,
			}),
			Bar = React.createElement(ProgressBar, {
				progress = progress,
				label = `{props.highestStage}/{TOTAL_STAGES}`,
				layoutOrder = 2,
			}),
		},
	})
end

return ProgressHud
