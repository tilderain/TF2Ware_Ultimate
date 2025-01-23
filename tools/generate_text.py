from PIL import Image, ImageDraw, ImageFont
import math
import os

def textsize(text, font):
    im = Image.new(mode="P", size=(0, 0))
    draw = ImageDraw.Draw(im)
    _, _, width, height = draw.textbbox((0, 0), text=text, font=font)
    return width, height

def generate_image_internal(name, text, color, idx):

    # Set the image size
    vmt_scale_x = 3
    vmt_scale_y = 14
    
    width = 1024
    if len(text) >= 15:
        vmt_scale_x = 1.5
        width = 2048
    elif len(text) <= 5:
        vmt_scale_x = 6
        width = 512
    height = 128
    
    font_size = 110

    # Create a transparent image
    image = Image.new('RGBA', (width, height), (0, 0, 0, 0))

    # Create a draw object
    draw = ImageDraw.Draw(image)

    # Set the font and size
    font_name = 'bin/tf2build.ttf'
    #font_path = 'C:/Users/Administrator/AppData/Local/Microsoft/Windows/Fonts/' + font_name 
    font_path = font_name
    font = ImageFont.truetype(font_path, size=font_size)
    
    if idx == 1:
        text = text[::-1]

    # Set the text and its position
    text_width, text_height = textsize(text, font=font)
    x = (width - text_width) / 2
    y = (height - text_height) / 2

    # Draw outline
    border = 8
    border_color = (0,0,0)
    points = 15
    for step in range(0, math.floor(border * points), 1):
        angle = step * 2 * math.pi / math.floor(border * points)
        draw.text((x - border * math.cos(angle), y - border * math.sin(angle)), text, border_color, font)

    # Draw the text
    draw.text((x, y), text, font=font, fill=color)

    image = image.transform(image.size, Image.AFFINE, (1, 0.2, 0, 0, 1, 0))

    image.thumbnail((width / 2, height / 2),Image.Resampling.LANCZOS)

    # Save the image
    file_name = name + str(idx) + '.png'
    image.save(file_name)
    
    if idx == 0:
        with open(f"../materials/hud/tf2ware_ultimate/minigames/{name}.vmt", "w") as f:
            f.write("UnlitGeneric\n{\n")
            f.write(f"\t$basetexture hud/tf2ware_ultimate/minigames/{name}\n")
            f.write(f"\t$basetexturetransform \"center .5 .2 scale {vmt_scale_x} {vmt_scale_y} rotate 0 translate 0 0\"\n")
            f.write("""
    $translucent 1
    $frame 0
    $world_mins "[0.0 0.0 0.0]"
	$world_maxs "[0.0 0.0 0.0]"
    $zero 0.0
    Proxies
    {
        WorldDims
        {
        }
        Clamp
        {
            srcVar1		$zero
            min			"$world_mins[0]"
            max			"$world_mins[0]"
            resultVar   $frame
        }
    }
""")
            f.write("}")
            
    return file_name

def generate_image(name, text, color):
    name1 = generate_image_internal(name, text, color, 0)
    name2 = generate_image_internal(name, text, color, 1)
    
    command = f"bin\\VTFCmd.exe -file {name1} -file {name2} -outname {name} -output \"../materials/hud/tf2ware_ultimate/minigames\" -format \"dxt5\" -alphaformat \"dxt5\" -flag CLAMPS -flag CLAMPT -nomipmaps -animated"
    
    if(os.name == "posix"):
        command = "wine " + command
    
    os.system(command)
    
    os.remove(name1)
    os.remove(name2)

file_name = str(input("Input file name, e.g. 'flash_flood'\n"))
the_text = str(input("Input text to display, e.g. 'FLASH FLOOD'\n"))
color = str(input("Color of the text, e.g. 'white' or '#123ABC'\n"))
generate_image(file_name, the_text, color);