--!strict
-- client/ui/primitives/Modal.luau
-- Centered modal overlay (React-Lua) (LEAD.md §1 p.9)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

export type ModalProps = {
	visible: boolean,
	title: string?,
	size: UDim2?,
	onClose: (() -> ())?,
	children: any?,
}

local OVERLAY_COLOR = Color3.new(0, 0, 0)
local OVERLAY_TRANSPARENCY = 0.5
local MODAL_BG = Color3.fromRGB(35, 35, 45)

local function Modal(props: ModalProps)
	if not props.visible then
		return nil
	end

	local headerChildren: { [string]: any } = {}

	if props.title then
		headerChildren.Title = React.createElement("TextLabel", {
			Text = props.title,
			Size = UDim2.new(1, -40, 0, 36),
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	end

	if props.onClose then
		headerChildren.CloseBtn = React.createElement("TextButton", {
			Text = "✕",
			Size = UDim2.new(0, 32, 0, 32),
			Position = UDim2.new(1, -32, 0, 2),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(180, 180, 190),
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			[React.Event.Activated] = props.onClose,
		})
	end

	return React.createElement("Frame", {
		-- Full-screen overlay
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = OVERLAY_COLOR,
		BackgroundTransparency = OVERLAY_TRANSPARENCY,
		BorderSizePixel = 0,
		ZIndex = 100,
	}, {
		ModalCard = React.createElement("Frame", {
			Size = props.size or UDim2.new(0, 400, 0, 300),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = MODAL_BG,
			BorderSizePixel = 0,
			ZIndex = 101,
		}, {
			Corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 12) }),
			Padding = React.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 16),
				PaddingBottom = UDim.new(0, 16),
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
			}),
			Header = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundTransparency = 1,
			}, headerChildren),
			Content = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, -52),
				Position = UDim2.new(0, 0, 0, 44),
				BackgroundTransparency = 1,
			}, props.children),
		}),
	})
end

return Modal
