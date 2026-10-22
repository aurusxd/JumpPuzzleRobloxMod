--!strict
-- client/ui/primitives/Button.luau
-- Reusable Button component (React-Lua) (LEAD.md §1 p.9)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

export type ButtonProps = {
	text: string,
	onClick: () -> (),
	disabled: boolean?,
	size: UDim2?,
	position: UDim2?,
	layoutOrder: number?,
	color: Color3?,
}

local DEFAULT_COLOR = Color3.fromRGB(60, 130, 255)
local DISABLED_COLOR = Color3.fromRGB(120, 120, 120)
local HOVER_COLOR = Color3.fromRGB(80, 150, 255)
local PRESS_COLOR = Color3.fromRGB(40, 100, 200)

local function Button(props: ButtonProps)
	local isHovered, setIsHovered = React.useState(false)
	local isPressed, setIsPressed = React.useState(false)

	local disabled = props.disabled or false
	local baseColor = props.color or DEFAULT_COLOR

	local currentColor: Color3
	if disabled then
		currentColor = DISABLED_COLOR
	elseif isPressed then
		currentColor = PRESS_COLOR
	elseif isHovered then
		currentColor = HOVER_COLOR
	else
		currentColor = baseColor
	end

	return React.createElement("TextButton", {
		Text = props.text,
		Size = props.size or UDim2.new(0, 200, 0, 50),
		Position = props.position,
		LayoutOrder = props.layoutOrder,
		BackgroundColor3 = currentColor,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		AutoButtonColor = false,
		Active = not disabled,

		[React.Event.MouseEnter] = function()
			if not disabled then
				setIsHovered(true)
			end
		end,
		[React.Event.MouseLeave] = function()
			setIsHovered(false)
			setIsPressed(false)
		end,
		[React.Event.MouseButton1Down] = function()
			if not disabled then
				setIsPressed(true)
			end
		end,
		[React.Event.MouseButton1Up] = function()
			setIsPressed(false)
		end,
		[React.Event.Activated] = function()
			if not disabled then
				props.onClick()
			end
		end,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		Padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}),
	})
end

return Button
