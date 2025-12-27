# Events
extends Node

# Battle Related Events
signal increment_turn_count

# Card Related Events
signal card_drag_started(card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)
signal card_played(card: Card)
signal card_resolved(card: Card)
signal reparent_card_to_play_from_hand_requested(card_ui: CardUI)
signal card_tooltip_popup_requested(card: Card)
signal card_zone_selection_requested(targets: Array[CardZone.Zone],new_card_played:Card,new_title:String)
signal card_zone_selection_finished(card_pile: CardPile)

# Card Pile Related Events
signal card_pile_view_requested(card_pile: CardPile,title: String,randomized, bool)
signal card_pile_selection_requested(new_card_played: Card, new_card_pile: CardPile, new_title: String)
signal card_pile_selection_finished(card_pile: CardPile)

# Player Related Events
# need to adjust each signal to include playerid (maybe)
signal player_turn_ended
signal ready_to_start_match(id,turn_order_roll: int)
signal current_turn_step_changed(new_state: TurnStepState)
signal initial_turn_step_entered(initial_state: TurnStepState)
signal out_of_actions
signal not_out_of_actions
signal draw_cards_requested(amount: int)
signal draw_specific_cards_requested(card_pile: CardPile)
signal discard_card_requested(card: Card)
signal discard_cards_requested(card_pile: CardPile)
signal on_card_draw_button_pressed
# The card_name is passed here so the RPC can set the same name for the remote node
# This allows for easier management of remote cards using get_node and card_name.
signal card_drawn(card: Card,card_name: String)
signal update_remote_player_stats(
	transfiguration_power_count: int,
	charms_power_count: int,
	potions_power_count: int,
	care_of_magical_creatures_power_count: int,
	quidditch_power_count: int,
	max_action_count: int,
	action_count: int
)

# Confirmation Events
signal confirmation_modal_ui_customize(header: String, message: String, confirm_text: String, cancel_text: String)
signal confirmation_modal_ui_prompt(pause: bool)
signal confirmation_modal_ui_response(answer: bool)

# Card Selection Related Events
#signal selected_cards_updated
