extends Node

# Card Related Events
signal card_drag_started(card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)
signal card_played(card: Card)
signal card_resolved(card: Card)
signal reparent_card_to_play_requested(card_ui: CardUI)
signal card_tooltip_popup_requested(card: Card)
signal card_area_selection_requested(targets: Array[CardZone.Zone],new_card_played:Card,new_title:String)
signal card_area_selection_finished(card_pile: CardPile)

# Card Pile Related Events
signal card_pile_view_requested(card_pile: CardPile,title: String,randomized, bool)
signal card_pile_selection_requested(new_card_played: Card, new_card_pile: CardPile, new_title: String)
signal card_pile_selection_finished(card_pile: CardPile)

# Player Related Events
signal draw_step_completed
signal out_of_actions
signal not_out_of_actions
signal draw_cards_requested(amount: int)
signal draw_specific_cards_requested(card_pile: CardPile)
signal discard_card_requested(card: Card)
signal discard_cards_requested(card_pile: CardPile)
signal player_end_of_turn_start
signal player_end_of_turn_finished
signal on_card_draw_button_pressed

# Confirmation Events
signal confirmation_modal_customize(header: String, message: String, confirm_text: String, cancel_text: String)
signal confirmation_modal_prompt(pause: bool)
signal confirmation_modal_response(answer: bool)

# Opponent Related Events
signal opponent_turn_ended

# Card Selection Related Events
#signal selected_cards_updated
