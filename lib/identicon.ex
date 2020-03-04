defmodule Identicon do

# receba o texto para enviar para a pipeline
  def main(input) do
    input
    |> hash_input   
    |> pick_color
    |> build_grid
    |> filter_odd_square
    |> build_pixel_map
    |> draw_image
    |> save_image(input)

  end

# faz o encript e converte para uma lista de inteiros
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |>:binary.bin_to_list
    %Identicon.Image { hex: hex }
  end

  def pick_color(image) do
    # pego o campo hex do image e apenas retiro os 3 primeiros valores
    %Identicon.Image { hex: [r, g, b | _tail] } = image
    # pego todos os campos do image, pego apenas os 3 valores rgb obtidos acima e atribuo na propriedade color
    %Identicon.Image { image | color: {r, g, b} } 
    
  end

  def build_grid(%Identicon.Image { hex: hex } = image) do
    grid = hex
    |> Enum.chunk(3)
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    |> Enum.with_index
  
    %Identicon.Image{ image | grid: grid }
  end

  def filter_odd_square(%Identicon.Image{ grid: grid } = image) do
    grid = Enum.filter grid, fn({code, _index }) -> 
      rem(code, 2) == 0 
    end

    %Identicon.Image{ image | grid: grid }
  end 

  def mirror_row(image) do
    [first, second | _tail] = image
    image ++ [second, first]
  end

  def build_pixel_map(%Identicon.Image{ grid: grid } = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal  = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = { horizontal, vertical }
      bottom_right = { horizontal + 50, vertical + 50 }

      { top_left, bottom_right }
    end

    %Identicon.Image{ image | pixel_map: pixel_map }
  end

  def draw_image(%Identicon.Image{ color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

      :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

end
