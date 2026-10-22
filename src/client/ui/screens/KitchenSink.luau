--!strict
-- client/ui/screens/KitchenSink.luau
-- Dev-only screen showing all UI primitives (LEAD.md §1 p.9)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local Button = require(script.Parent.Parent.primitives.Button)
local Panel = require(script.Parent.Parent.primitives.Panel)
local Label = require(script.Parent.Parent.primitives.Label)
local ListItem = require(script.Parent.Parent.primitives.ListItem)
local ProgressBar = require(script.Parent.Parent.primitives.ProgressBar)
local Modal = require(script.Parent.Parent.primitives.Modal)

local function KitchenSink()
	local progress, setProgress = React.useState(0.35)
	local modalVisible, setModalVisible = React.useState(false)
	local selectedItem, setSelectedItem = React.useState(1)

	return React.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 12),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		-- Title
		Title = React.createElement(Label, {
			text = "Kitchen Sink — UI Primitives",
			textSize = 24,
			font = Enum.Font.GothamBold,
			xAlignment = Enum.TextXAlignment.Center,
			layoutOrder = 1,
		}),

		-- Buttons row
		ButtonPanel = React.createElement(Panel, {
			size = UDim2.new(0, 500, 0, 120),
			layoutOrder = 2,
			children = {
				BtnLayout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 12),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Btn1 = React.createElement(Button, {
					text = "Default",
					layoutOrder = 1,
					onClick = function()
						setProgress(math.clamp(progress + 0.1, 0, 1))
					end,
				}),
				Btn2 = React.createElement(Button, {
					text = "Colored",
					color = Color3.fromRGB(200, 80, 60),
					layoutOrder = 2,
					onClick = function()
						setProgress(math.clamp(progress - 0.1, 0, 1))
					end,
				}),
				Btn3 = React.createElement(Button, {
					text = "Disabled",
					disabled = true,
					layoutOrder = 3,
					onClick = function() end,
				}),
			},
		}),

		-- Progress bar
		ProgressPanel = React.createElement(Panel, {
			size = UDim2.new(0, 500, 0, 80),
			layoutOrder = 3,
			children = {
				Bar = React.createElement(ProgressBar, {
					progress = progress,
					label = `Stage {math.floor(progress * 30)}/30`,
				}),
			},
		}),

		-- List items
		ListPanel = React.createElement(Panel, {
			size = UDim2.new(0, 500, 0, 200),
			layoutOrder = 4,
			children = {
				ListLayout = React.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
				}),
				Item1 = React.createElement(ListItem, {
					text = "Ember Blob",
					subText = "Common · Ember",
					layoutOrder = 1,
					selected = selectedItem == 1,
					onClick = function()
						setSelectedItem(1)
					end,
				}),
				Item2 = React.createElement(ListItem, {
					text = "Tide Jelly",
					subText = "Common · Tide",
					layoutOrder = 2,
					selected = selectedItem == 2,
					onClick = function()
						setSelectedItem(2)
					end,
				}),
			},
		}),

		-- Modal trigger
		ModalBtn = React.createElement(Button, {
			text = "Open Modal",
			layoutOrder = 5,
			onClick = function()
				setModalVisible(true)
			end,
		}),

		-- Modal
		TestModal = React.createElement(Modal, {
			visible = modalVisible,
			title = "Creature Obtained!",
			onClose = function()
				setModalVisible(false)
			end,
			children = {
				Msg = React.createElement(Label, {
					text = "You received: Ember Blob",
					textSize = 18,
					xAlignment = Enum.TextXAlignment.Center,
				}),
			},
		}),
	})
end

return KitchenSink
