defmodule Identicon do
  def main(input) do
    input
    #helper functions
    |> hash_input # return value is a struct
    #return value of hash_input is sent to pick_color through the pipe
    |> pick_color
    #return value from pick_color will go into build_grid
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    
  end

  

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end
    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index }) -> 
      rem(code,2) == 0 #caculates the remainder
    end

    %Identicon.Image{image | grid: grid}
  end


#this function will be called with image struct
  def build_grid(%Identicon.Image{hex: hex } = image) do
    #enum.chunk(3) will take an array and make an array of arrays with 3 numbers in each array
    grid = 
      hex
      |>Enum.chunk(3) #Enum.chunk(hex, 3) is whats going on here
      |>Enum.map(&mirror_row/1) #takes an array pass a function. whatever is returned from the function will be put into a new array
      |>List.flatten #will take a nested list and put the values in one list
      |>Enum.with_index #takes every element in the list and turns it into a two element tupil the first is the element the second is the index
    
     %Identicon.Image{image | grid: grid}
  end
  
  #this fuction will return an updated row that has mirrored numbers. DOES NOT CHANGE ORIGINAL ROW
  def mirror_row(row) do
    # [145 ,46 , 200] is what it looks like
    [first, second | _tail] = row

    # [145, 46, 200, 46, 145] this is what i want
    # row++ is how you join arrays together
    row ++ [second, first]
  end

#this function returns image struct
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    #this functions job is to pull the first 3 numbers in the hex array
    #the pipe and _tail means i know theres more then 3 values in this array 
    #pattern matching starts on the left hand side
    # %Identicon.Image{hex: [r, g, b | _tail]} = image this line of code can be passed as the argument
    
    #returning and updating property this is a copy of the struct and modifying it
    %Identicon.Image{image | color: {r, g, b}}
  end

  #javascript code to do what that function just did
  #pick_color: function(image){
    #image.color = {
     # r: image.hex[0],
      #g: image.hex[1],
      #b: image.hex[2]
    #};
    #return image
  #};

  #hash input function returns an array of hex codes from the hashing function
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
  #passing back image struct
  # use a struct when yout know the properites you will be working with
    %Identicon.Image{hex: hex}
  end
end
