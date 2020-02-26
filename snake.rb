require "ruby2d"

set background: "navy"
set fps_cap: 20
set title: "SNAKE"

# width = 640 / 20 = 32
# height = 480 / 20 = 24


set width: 640, height: 480 # Note: This line is option since the value is same as default

GRID_SIZE = 20
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE

class Snake
    attr_writer :direction

    def initialize
        @positions = [[2, 0], [2, 1], [2, 2], [2, 3]]
        @direction = "down"
        @growing = false
    end

    def draw
        @positions.each do |position|
            Square.new(x: position[0] * GRID_SIZE, y: position[1] * GRID_SIZE, size: GRID_SIZE - 2, color: "white")
        end
    end


    def move
        if !@growing
            @positions.shift
        end

        case @direction
        when "down"
            @positions.push(new_coords(head[0], head[1] + 1))
        when "up"
            @positions.push(new_coords(head[0], head[1] - 1))
        when "left"
            @positions.push(new_coords(head[0] - 1, head[1]))
        when "right"
            @positions.push(new_coords(head[0] + 1, head[1]))
        end

        @growing = false
    end


    def can_change_direction_to?(new_direction)
        case @direction
        when "up" then new_direction != "down"
        when "down" then new_direction != "up"
        when "left" then new_direction != "right"
        when "right" then new_direction != "left"
        end
    end

    def x
        head[0]
    end

    def y
        head[1]
    end

    def grow
        @growing = true
    end

    def hit_itself?
        @positions.uniq.length != @positions.length
    end

    private

    def new_coords(x, y)
        [x % GRID_WIDTH, y % GRID_HEIGHT]
    end

    def head
        @positions.last
    end
end


class Game
    def initialize
        @score = 0
        @ball_x = rand(GRID_WIDTH)
        @ball_y = rand(GRID_HEIGHT)
        @finished = false
        @started = false
    end

    def draw_intro

        Text.new(
            'START              QUIT',
            x: 110,
            y: Window.height - 200,
            size: 40,
            color: 'white',
            z: 50
        )

        # START Button
        Rectangle.new(
          x: 100,
          y: Window.height - 200,
          width: 150, height: 60,
          color: 'green',
          z: 20
        )

        # QUIT button
        Rectangle.new(
          x: Window.width - 270,
          y: Window.height - 200,
          width: 150, height: 60,
          color: 'red',
          z: 20
        )

    end

    def draw_game
        if started? && !finished?
            Square.new(x: @ball_x * GRID_SIZE, y: @ball_y * GRID_SIZE, size: GRID_SIZE, color: "yellow")
        end

        Text.new(text_message, color: "green", x: 10, y: 10, size: 25)
    end

    def snake_hit_ball?(x, y)
        @ball_x == x && @ball_y == y
    end

    def record_hit
        @score += 1
        @ball_x = rand(GRID_WIDTH)
        @ball_y = rand(GRID_HEIGHT)
    end

    def finish
        @finished= true
    end

    def finished?
        @finished
    end

    def start
        @started = true
    end

    def started?
        @started
    end

    private

    def text_message
        if finished?
            "Game over, your score was: #{@score}. Press 'R' to restart. "
        else
            "Score: #{@score}"
        end
    end
end


snake = Snake.new
game = Game.new

update do
    clear

    if !game.started?
        game.draw_intro
    end

    if game.started? and !game.finished?
        snake.move
    end

    if game.started?
        snake.draw
        game.draw_game

        if game.snake_hit_ball?(snake.x, snake.y)
            game.record_hit
            snake.grow
        end

        if snake.hit_itself?
            game.finish
        end
    end

end

on :mouse_down do |event|
  # x and y coordinates of the mouse button event
  if !game.started?
      if 100 < event.x and event.x < 250 and Window.height - 200 < event.y and event.y < Window.height - 140 then
          puts "start"
          game.start
      elsif Window.width - 270 < event.x and event.x < Window.width - 120 and Window.height - 200 < event.y and event.y < Window.height - 140 then
          puts "QUIT"
          close
      end
  end
end


on :key_down do |event|
    if ["up", "down", "left", "right"].include?(event.key)
        if snake.can_change_direction_to?(event.key)
            snake.direction = event.key
        end

    elsif event.key == "r"
        snake = Snake.new
        game = Game.new
    end
end

show
