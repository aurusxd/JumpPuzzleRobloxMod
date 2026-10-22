--!strict
-- client/ui/primitives/Label.luau
-- Reusable text Label (React-Lua) (LEAD.md §1 p.9)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

export type LabelProps = {
	text: string,
	size: UDim2?,
	position: UDim2?,
	textSize: number?,
	font: Enum.Font?,
	color: Color3?,
	xAlignment: Enum.TextXAlignment?,
	yAlignment: Enum.TextYAlignment?,
	layoutOrder: number?,
	richText: boolean?,
}

local function Label(props: LabelProps)
	return React.createElement("TextLabel", {
		Text = props.text,
		Size = props.size or UDim2.new(1, 0, 0, 30),
		Position = props.position,
		BackgroundTransparency = 1,
		TextColor3 = props.color or Color3.new(1, 1, 1),
		Font = props.font or Enum.Font.GothamMedium,
		TextSize = props.textSize or 16,
		TextXAlignment = props.xAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.yAlignment or Enum.TextYAlignment.Center,
		LayoutOrder = props.layoutOrder,
		RichText = props.richText or false,
		TextWrapped = true,
	})
end

return Label
