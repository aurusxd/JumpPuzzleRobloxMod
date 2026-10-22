--!strict
-- client/ui/primitives/ProgressBar.luau
-- Animated progress bar (React-Lua) (LEAD.md §1 p.9)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

export type ProgressBarProps = {
	progress: number, -- 0..1
	size: UDim2?,
	position: UDim2?,
	barColor: Color3?,
	backgroundColor: Color3?,
	layoutOrder: number?,
	label: string?,
}

local DEFAULT_BAR_COLOR = Color3.fromRGB(60, 200, 80)
local DEFAULT_BG_COLOR = Color3.fromRGB(50, 50, 60)

local function ProgressBar(props: ProgressBarProps)
	local progress = math.clamp(props.progress, 0, 1)

	return React.createElement("Frame", {
		Size = props.size or UDim2.new(1, 0, 0, 24),
		Position = props.position,
		BackgroundColor3 = props.backgroundColor or DEFAULT_BG_COLOR,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
	}, {
		Corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Fill = React.createElement("Frame", {
			Size = UDim2.new(progress, 0, 1, 0),
			BackgroundColor3 = props.barColor or DEFAULT_BAR_COLOR,
			BorderSizePixel = 0,
		}, {
			FillCorner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
		}),
		Label = if props.label
			then React.createElement("TextLabel", {
				Text = props.label,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				ZIndex = 2,
			})
			else nil,
	})
end

return ProgressBar
