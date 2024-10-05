package balls

import "vendor:raylib"
import "core:math/rand"
import "core:math"
import "core:fmt"
import "core:strings"
import "core:strconv"

SCREEN_WIDTH :: 1000
SCREEN_HEIGHT :: 650
RADIUS :: 20
FAT_RATE :: 3
COIN_RADIUS :: 20
TRAVEL_RATE :: 8

Ball :: struct {
	x: i32,
	y: i32,
	radius: i32,
}

Direction :: enum {
	RIGHT, 
	LEFT,
	UP,
	DOWN
}

GenerateRandomCoin :: proc(coin: ^Ball, ball: ^Ball) {
		coin.x = cast(i32)rand.uint32()%SCREEN_WIDTH
		coin.y = cast(i32)rand.uint32()%SCREEN_HEIGHT
		
		if coin.x < 0 {
			coin.x = coin.x*-1  
		}

		if coin.y < 0 {
			coin.y = coin.y*-1  
		}
}

Reached :: proc (pos: ^Ball, direction: Direction) -> bool {
	  switch direction {
		case .LEFT:
			return pos.x - pos.radius - TRAVEL_RATE <= 0
		case .RIGHT:
			return pos.x + pos.radius + TRAVEL_RATE >= SCREEN_WIDTH
		case .UP:
			return pos.y - pos.radius - TRAVEL_RATE <= 0
		case .DOWN:
			return pos.y + pos.radius + TRAVEL_RATE >= SCREEN_HEIGHT
		}

		return false
}

Collided :: proc (ball: ^Ball, coin: ^Ball) -> bool {
		x1 := cast(f32)ball.x
		x2 := cast(f32)coin.x 
		y1 := cast(f32)ball.y
		y2 := cast(f32)coin.y


	  return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2)) < (cast(f32)ball.radius + cast(f32)coin.radius)
}


scoreCard :: proc(score: int) {
	buf : [4]byte
	txt := [?]string {
		 "SCORE CARD: ",
		 strconv.itoa(buf[:], score)
	}

	raylib.DrawText(strings.clone_to_cstring(strings.concatenate(txt[:])), 20, 20, 20, raylib.GREEN)
}

GameOver :: proc() {
	raylib.DrawText(strings.clone_to_cstring("GAME OVER"), 200, 250, 100, raylib.GREEN)
}


GameComplete :: proc() {
	raylib.DrawText(strings.clone_to_cstring("GAME Complete"), 200, 250, 100, raylib.GREEN)
}

Score :: struct {
	score: int
}

main :: proc () {
	 raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Balls") 
	 gameOver := false
	 gameComplete := false
	 score := &Score{
		 0  
	 }

	 balls := &Ball{
		 SCREEN_WIDTH/2,
		 SCREEN_HEIGHT/2,
		 RADIUS,
	 }

	 coin := &Ball{
		  100,
			100,
			COIN_RADIUS,
	 }

	 raylib.SetTargetFPS(90)

	 for !raylib.WindowShouldClose() {
		 if raylib.IsKeyDown(raylib.KeyboardKey.DOWN) {
			 		if Reached(balls, Direction.DOWN) {
						  balls.y -= 50*TRAVEL_RATE
				 			score.score -= 3
					} else {
						  balls.y += TRAVEL_RATE
					}
		 }

		 if raylib.IsKeyDown(raylib.KeyboardKey.UP) && !Reached(balls, Direction.UP) {
			  balls.y -= TRAVEL_RATE 
		 }

		 if raylib.IsKeyDown(raylib.KeyboardKey.RIGHT){
			 if Reached(balls, Direction.RIGHT) {
				 balls.x -= 50*TRAVEL_RATE  
				 score.score -= 3
			 } else {
				 balls.x += TRAVEL_RATE  
			 }
		 }

		 if raylib.IsKeyDown(raylib.KeyboardKey.LEFT) && !Reached(balls, Direction.LEFT) {
			 balls.x -= TRAVEL_RATE  
		 }

		 if raylib.IsKeyDown(raylib.KeyboardKey.G)  {
			 gameOver = true  
		 }

		 if raylib.IsKeyPressed(raylib.KeyboardKey.R) {
			 score.score = score.score/2
			 GenerateRandomCoin(coin, balls)
			 if balls.radius > RADIUS {
			 		balls.radius = 5*balls.radius/6
			 }
		 }

		 if (balls.radius/3 > SCREEN_HEIGHT && balls.radius/3 > SCREEN_WIDTH) {
			 gameComplete = true  
		 }


		  raylib.BeginDrawing() 
				raylib.ClearBackground(raylib.BLACK)
				scoreCard(score.score)

				if gameOver {
					GameOver()
				} else if gameComplete {
					GameComplete()  
				} else {
					gamePlay(balls, coin, score)  
				}

			raylib.EndDrawing()
	 }

	 raylib.CloseWindow()
}

gamePlay :: proc (ball: ^Ball, coin: ^Ball, score: ^Score) {
				raylib.DrawCircle(ball.x, ball.y, cast(f32)ball.radius, raylib.MAROON)
				if Collided(ball, coin) {
					ball.radius += FAT_RATE
					score.score += 10
					GenerateRandomCoin(coin, ball)
				} else {
					raylib.DrawCircle(coin.x, coin.y, cast(f32)coin.radius, raylib.YELLOW)
				}
				raylib.DrawCircle(ball.x, ball.y, cast(f32)ball.radius/3, raylib.BLACK)
}

