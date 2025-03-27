package models

import (
	"time"
)

// User represents a player in the lottery system
type User struct {
	ID        int       `json:"id"`
	Username  string    `json:"username"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// GameType represents the type of lottery game
type GameType string

const (
	// GameTypeMega represents the Mega 6/45 game
	GameTypeMega GameType = "mega_6_45"
	// GameTypePower represents the Power 6/55 game
	GameTypePower GameType = "power_6_55"
)

// Ticket represents a lottery ticket
type Ticket struct {
	ID              int       `json:"id"`
	UserID          int       `json:"user_id"`
	GameType        GameType  `json:"game_type"`
	Numbers         []int     `json:"numbers"`
	CreatedAt       time.Time `json:"created_at"`
	DrawingID       *int      `json:"drawing_id,omitempty"`
	PrizeCategoryID *int      `json:"prize_category_id,omitempty"`
}

// Drawing represents a lottery drawing
type Drawing struct {
	ID          int       `json:"id"`
	GameType    GameType  `json:"game_type"`
	Numbers     []int     `json:"numbers"`
	BonusNumber *int      `json:"bonus_number,omitempty"` // Only used for Power 6/55
	DrawTime    time.Time `json:"draw_time"`
	CreatedAt   time.Time `json:"created_at"`
}

// PrizeCategory represents a prize category in a lottery game
type PrizeCategory struct {
	ID              int      `json:"id"`
	GameType        GameType `json:"game_type"`
	Name            string   `json:"name"`
	MatchCount      int      `json:"match_count"`
	IncludeBonus    bool     `json:"include_bonus"`
	PrizeAmount     float64  `json:"prize_amount"`
	PrizePercentage float64  `json:"prize_percentage"`
}

// DrawingResult represents the result of a ticket in a drawing
type DrawingResult struct {
	ID              int       `json:"id"`
	TicketID        int       `json:"ticket_id"`
	DrawingID       int       `json:"drawing_id"`
	MatchedNumbers  []int     `json:"matched_numbers"`
	MatchedBonus    bool      `json:"matched_bonus"`
	PrizeCategoryID *int      `json:"prize_category_id,omitempty"`
	PrizeAmount     *float64  `json:"prize_amount,omitempty"`
	CreatedAt       time.Time `json:"created_at"`
}

// ValidationError represents an error validating user input
type ValidationError struct {
	Field   string `json:"field"`
	Message string `json:"message"`
}

// ErrorResponse represents an error response from the API
type ErrorResponse struct {
	Status  int               `json:"status"`
	Message string            `json:"message"`
	Errors  []ValidationError `json:"errors,omitempty"`
}
