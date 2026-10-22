--!strict
-- client/ui/primitives/Panel.luau
-- Reusable Panel container (React-Lua) (LEAD.md §1 p.9)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

export type PanelProps = {
	size: UDim2?,
	position: UDim2?,
	anchorPoint: Vector2?,
	color: Color3?,
	transparency: number?,
	layoutOrder: number?,
	children: any?,
}

local DEFAULT_COLOR = Color3.fromRGB(30, 30, 40)
local DEFAULT_TRANSPARENCY = 0.15

local function Panel(props: PanelProps)
	return React.createElement("Frame", {
		Size = props.size or UDim2.new(0, 300, 0, 400),
		Position = props.position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
		BackgroundColor3 = props.color or DEFAULT_COLOR,
		BackgroundTransparency = props.transparency or DEFAULT_TRANSPARENCY,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		Padding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 16),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
		}),
		Children = React.createElement(React.Fragment, nil, props.children),
	})
end

return Panel
