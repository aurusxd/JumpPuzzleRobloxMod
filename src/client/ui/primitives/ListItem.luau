--!strict
-- client/ui/primitives/ListItem.luau
-- Reusable list row (React-Lua) (LEAD.md §1 p.9)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

export type ListItemProps = {
	text: string,
	subText: string?,
	icon: string?, -- rbxassetid://
	onClick: (() -> ())?,
	layoutOrder: number?,
	selected: boolean?,
}

local DEFAULT_BG = Color3.fromRGB(45, 45, 55)
local SELECTED_BG = Color3.fromRGB(60, 130, 255)
local ITEM_HEIGHT = 56

local function ListItem(props: ListItemProps)
	local bgColor = if props.selected then SELECTED_BG else DEFAULT_BG

	local children: { [string]: any } = {
		Corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}),
		Title = React.createElement("TextLabel", {
			Text = props.text,
			Size = UDim2.new(1, if props.icon then -48 else 0, 0, if props.subText then 24 else ITEM_HEIGHT),
			Position = UDim2.new(0, if props.icon then 48 else 0, 0, 4),
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamMedium,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	}

	if props.subText then
		children.SubTitle = React.createElement("TextLabel", {
			Text = props.subText,
			Size = UDim2.new(1, if props.icon then -48 else 0, 0, 20),
			Position = UDim2.new(0, if props.icon then 48 else 0, 0, 28),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(180, 180, 190),
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	end

	if props.icon then
		children.Icon = React.createElement("ImageLabel", {
			Image = props.icon,
			Size = UDim2.new(0, 36, 0, 36),
			Position = UDim2.new(0, 0, 0.5, -18),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
		})
	end

	if props.onClick then
		return React.createElement("TextButton", {
			Text = "",
			Size = UDim2.new(1, 0, 0, ITEM_HEIGHT),
			BackgroundColor3 = bgColor,
			BorderSizePixel = 0,
			LayoutOrder = props.layoutOrder,
			AutoButtonColor = false,
			[React.Event.Activated] = props.onClick,
		}, children)
	end

	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, ITEM_HEIGHT),
		BackgroundColor3 = bgColor,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
	}, children)
end

return ListItem
