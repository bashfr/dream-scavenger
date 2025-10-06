package ds
import "core:c"
import "core:fmt"
import "core:mem"
import "core:time"
import rl "vendor:raylib"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720

main :: proc() {

	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	defer {
		for _, entry in track.allocation_map {
			fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
		}
		for entry in track.bad_free_array {
			fmt.eprintf("%v bad free\n", entry.location)
		}
		mem.tracking_allocator_destroy(&track)
	}

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Dreams Scavenger")
	rl.InitAudioDevice()
	rl.SetTextLineSpacing(1)
	rl.SetTargetFPS(60)


	music_stream: rl.Music
	music_stream2: rl.Music
	chapter1 := rl.LoadMusicStream("resources/test.mp3")
	chapter2 := rl.LoadMusicStream("resources/chapter2.mp3")
	chapter3 := rl.LoadMusicStream("resources/chapter3.mp3")
	falling := rl.LoadMusicStream("resources/falling.mp3")
	falling_inverted := rl.LoadMusicStream("resources/falling-inverted.mp3")
	noise := rl.LoadMusicStream("resources/noise.mp3")
	rl.PlayMusicStream(noise)
	rl.PlayMusicStream(music_stream)
	rl.PlayMusicStream(music_stream2)
	rl.PlayMusicStream(chapter1)
	rl.PlayMusicStream(falling)
	rl.PlayMusicStream(falling_inverted)
	rl.PlayMusicStream(chapter2)
	rl.PlayMusicStream(chapter3)

	boom_edited := rl.LoadSound("resources/boom-edited.mp3")
	text_sound := rl.LoadSound("resources/text-sound.mp3")
	door_opened := rl.LoadSound("resources/door-opened.mp3")
	door_opened_key := rl.LoadSound("resources/door-opened-key.mp3")
	door_locked := rl.LoadSound("resources/door-locked.mp3")
	heck := rl.LoadSound("resources/heck.mp3")
	key_taken := rl.LoadSound("resources/key-taken.mp3")
	talk_sound := rl.LoadSound("resources/talk-sound.mp3")
	walk := rl.LoadSound("resources/walk.mp3")
	walk_apartment := rl.LoadSound("resources/walk-apartment.mp3")
	walk_apartment_2 := rl.LoadSound("resources/walk-apartment-2.mp3")
	walk_wall := rl.LoadSound("resources/walk-wall.mp3")
	stand_up_2 := rl.LoadSound("resources/standup-2.mp3")
	photo_sound := rl.LoadSound("resources/photo_sound.mp3")
	diary_sound := rl.LoadSound("resources/diary-sound.mp3")
	backpack_sound := rl.LoadSound("resources/backpack-sound.mp3")

	hero := rl.LoadImage("resources/hero.png")
	hero_texture := rl.LoadTextureFromImage(hero)
	particle := rl.LoadImage("resources/particle.png")
	particle_texture := rl.LoadTextureFromImage(particle)


	font := rl.LoadFont("resources/pixantiqua.ttf")

	level: int = 000

	previous_level: int
	frames_counter: int

	skip_playroom: bool
	skip_bedroom: bool
	skip_kitchen: bool
	skip_heck: bool
	skip_photo: bool
	skip_diary: bool
	skip_diary2: bool
	skip_kitchen_description: bool
	photo_taken: bool
	diary_taken: bool
	saw_hanged_man: bool
	kitchen_key_taken: bool

	rl.GuiSetFont(font)

	// set_music :: proc(m: cstring) -> cstring{
	// 	return rl.LoadMusicStream(m)
	// }

	draw :: proc(text: cstring) {
		// frame: int
		// if rl.IsKeyDown(.SPACE) do frame += 8
		// else do frame += 2
		// text_length := rl.MeasureText(text, 20)
		// fmt.println(text_length)
		// for frame in 0 ..= text_length {
		// 	rl.DrawText(rl.TextSubtext(text, 0, i32(frame / 10)), 210, 160, 20, rl.WHITE)
		// }
		rl.DrawText(text, 100, 160, 20, rl.WHITE)
	}

	draw_centered :: proc(text: cstring, frame: int) {
		length := rl.MeasureText(text, 20)
		rl.DrawText(
			rl.TextSubtext(text, 0, i32(frame / 5)),
			SCREEN_WIDTH / 2 - length / 2,
			SCREEN_HEIGHT / 2,
			20,
			rl.WHITE,
		)
	}
	draw_static :: proc(text: cstring) {
		length := rl.MeasureText(text, 20)
		rl.DrawText(text, SCREEN_WIDTH / 2 - length / 2, SCREEN_HEIGHT / 2, 20, rl.WHITE)
	}

	draw_gray :: proc(text: cstring, frame: int) {
		length := rl.MeasureText(text, 20)
		rl.DrawText(
			rl.TextSubtext(text, 0, i32(frame / 10)),
			SCREEN_WIDTH / 2 - length / 2,
			SCREEN_HEIGHT / 2,
			20,
			rl.GRAY,
		)
	}

	draw_under_picture :: proc(text: cstring, frame: int) {
		length := rl.MeasureText(text, 20)
		rl.DrawText(
			rl.TextSubtext(text, 0, i32(frame / 5)),
			SCREEN_WIDTH / 2 - length / 2,
			SCREEN_HEIGHT - 200,
			20,
			rl.WHITE,
		)

	}

	draw_rotated :: proc(text: cstring, frame: int, font: rl.Font) {
		length := rl.MeasureText(text, 20)
		rl.DrawTextPro(
			font,
			rl.TextSubtext(text, 0, i32(frame / 5)),
			{f32(SCREEN_WIDTH / 2 + length / 2), f32(SCREEN_HEIGHT / 2)},
			{},
			180.0,
			20,
			0,
			rl.WHITE,
		)
	}

	// particle_under_picture :: proc(text: cstring, frame: int) {
	// 	length := rl.MeasureText(text, 20)
	// 	rl.DrawText(
	// 		rl.TextSubtext(text, 0, i32(frame / 10)),
	// 		SCREEN_WIDTH / 2 - length / 2,
	// 		SCREEN_HEIGHT - 200,
	// 		20,
	// 		rl.BLUE,
	// 	)
	// }

	particle_under_picture :: proc(text: cstring, frame: int, font: rl.Font) {
		length := rl.MeasureText(text, 20)
		rl.DrawTextPro(
			font,
			rl.TextSubtext(text, 0, i32(frame / 5)),
			{f32(SCREEN_WIDTH / 2 - length / 2), f32(SCREEN_HEIGHT - 200)},
			{},
			0,
			20,
			0,
			rl.BLUE,
		)
	}

	particle_centered :: proc(text: cstring, frame: int, font: rl.Font) {
		length := rl.MeasureText(text, 20)
		rl.DrawTextPro(
			font,
			rl.TextSubtext(text, 0, i32(frame / 10)),
			{f32(SCREEN_WIDTH / 2 - length / 2), f32(SCREEN_HEIGHT / 2)},
			{},
			0,
			20,
			0,
			rl.BLUE,
		)
	}

	draw_hero :: proc(texture: rl.Texture) {
		rl.DrawTexture(
			texture,
			SCREEN_WIDTH / 2 - texture.width / 2,
			SCREEN_HEIGHT / 2 - texture.height / 2 - 40,
			rl.WHITE,
		)
	}

	draw_particle :: proc(texture: rl.Texture) {
		rl.DrawTexture(
			texture,
			SCREEN_WIDTH / 2 - texture.width / 2,
			SCREEN_HEIGHT / 2 - texture.height / 2 - 40,
			rl.WHITE,
		)
	}

	action1 :: proc(text: cstring) {
		rl.DrawText(text, 100, 500, 20, rl.GRAY)
	}
	action2 :: proc(text: cstring) {
		rl.DrawText(text, 100, 550, 20, rl.GRAY)
	}
	action3 :: proc(text: cstring) {
		rl.DrawText(text, 100, 600, 20, rl.GRAY)
	}

	lore1 :: proc(text: cstring) {
		length := rl.MeasureText(text, 20)
		rl.DrawText(text, SCREEN_WIDTH - length - 100, 600, 20, rl.GRAY)
	}

	action_enter :: proc() {
		length := rl.MeasureText(">", 20)
		rl.DrawText(">", SCREEN_WIDTH / 2 - length / 2, SCREEN_HEIGHT - 50, 20, rl.GRAY)
	}

	for !rl.WindowShouldClose() {
		rl.UpdateMusicStream(music_stream)
		mouse_point := rl.GetMousePosition()
		btn_action := false


		if rl.IsKeyDown(.SPACE) do frames_counter += 8
		else do frames_counter += 2

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)


		camera := rl.Camera2D {
			zoom = 1,
		}

		rl.BeginMode2D(camera)

		switch level {
		case 000:
			draw_centered(
				"This game have a lot of audio.\nPlease, turn on sound and use headphones <3\nThe '>' symbol at the bottom of the screen says 'Press the Enter key!'.\nYou can also scroll faster holding Space button.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 8001
			}

		case 8001:
			draw_centered("Oh, and one more thing.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 8002
				frames_counter = 0
				music_stream = noise
			}
		case 8002:
			draw_gray("Don't lost your Self.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 8003
				frames_counter = 0
			}

		case 8003:
			draw_gray(":)", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 002
				frames_counter = 0
			}

		case 002:
			draw_centered("Dreams.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level += 1
			}

		case 003:
			draw_centered(
				"People are surrounded by dreams, living them and finding the strength\n\n" +
				"in them to continue doing what they are doing.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level += 1
			}

		case 004:
			draw_centered("It's their dream within a dream.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level += 1
			}

		case 005:
			draw_centered(
				"But I live in the dreams themselves and collect them to Assemble myself.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level += 1
			}

		case 006:
			draw_centered(
				"Everyone has their own dreams, good or bad.\n\nI take what looks familiar for me from everyone and put it in my backpack.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level += 1
				frames_counter = 0
			}

		case 007:
			draw_hero(hero_texture)
			draw_under_picture("It's me, by the way.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level += 1
			}


		case 008:
			draw_hero(hero_texture)
			draw_under_picture("Or, more precisely, how I seem to myself.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level += 1
			}


		case 009:
			draw_centered(
				"There are no clear rules in dreams, everything in them is constantly changing,\nincluding reflections in mirrors.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level += 1
			}

		case 010:
			draw_centered(
				"Only the most important Particles remain unchanged.\nLittle things that hold a part of a person.\nPerhaps I can feel something of myself in these parts.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level += 1
			}

		case 011:
			draw_centered(
				"I ended up in This dream by accident, without the help of the Landlord of the Universe.\nThese are the people in whose dreams I am.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level += 1
			}
			if rl.IsKeyPressed(.ONE) do level = 9002 // TODO: LandLord of Universe?
			if rl.IsKeyPressed(.TWO) do level = 9003 // TODO: Inner World?

		case 012:
			draw_centered(
				"Endless gray platforms are piled on top of each other\nas if they fell from the sky.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level += 1
			}

		case 013:
			draw_centered(
				"But I can't see the sky from here:\neverything is hidden by huge buildings.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level += 1
			}

		case 014:
			draw_centered(
				"How do I find the particles here?\nAnd do they exist here at all?",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level += 1
			}

		case 015:
			draw_centered("I need to find it out.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) do level = 100

		case 100:
			draw(
				"I'm sitting in a cramped hallway.\n\nTo my left and in front of me, at the very end, there are unopened doors.",
			)
			action1("1. Open left door")
			// action2("2. Open right door")
			action2("2. Open far door")
			if rl.IsKeyPressed(.ONE) {
				level = 110
				frames_counter = 0
				rl.PlaySound(door_locked)
			} // Open left door
			if rl.IsKeyPressed(.TWO) {
				if skip_heck {
					level = 131
					// rl.PlaySound(talk_sound)
				} else {
					level = 1300
					rl.PlaySound(door_opened)
				}
			} // Open far door

		case 110:
			draw_centered("This door is locked, there is no key around.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 100
				rl.PlaySound(walk)
			} // Go back

		case 120:
			// Open the right door. TODO: -door opens-
			draw("I can't see anything here, but there's a small switch to my right.")
			action1("1. Use the switch")
			action2("2. Go back")
			if rl.IsKeyPressed(.ONE) do level = 121
			if rl.IsKeyPressed(.TWO) {
				level = 100 // Go back
				rl.PlaySound(walk)
			}

		// case 121:
		// 	// Use the switch
		// 	draw("God.") // TODO: -SOMEONE'S DEAD, LOUD NOISE-
		// 	action_enter()
		// 	if rl.IsKeyPressed(.ENTER) do level = 122 // Go back

		case 1201:
			draw("I will never open that door again. I've seen enough")
			action_enter()
			if rl.IsKeyPressed(.ENTER) do level = previous_level // Go back

		case 122:
			//TODO: -switch used again, door closed quickly and loudly-
			draw("I never want to see him again.")
			action_enter()
			if rl.IsKeyPressed(.ENTER) do level = 100 // Go back
			saw_hanged_man = true

		case 1300:
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 130
				rl.PlaySound(heck)
				rl.PauseMusicStream(music_stream)
			}

		case 130:
			// Open far door
			skip_heck = true

			draw_static("Heck!")
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 131
				// rl.PlaySound(talk_sound)
			}

		case 131:
			draw(
				"There is no room here, only the strange roof is visible from above\nand a huge chasm to nowhere.\nIt seems like I have no other choice...",
			)
			action1("1. Jump off!")
			action2("2. Go back")
			if rl.IsKeyPressed(.ONE) {
				frames_counter = 0
				level = 132
				rl.UpdateMusicStream(falling)
			}
			if rl.IsKeyPressed(.TWO) {
				level = 100 // Go back
				rl.PlaySound(walk)
			}

		case 132:
			music_stream = falling
			// 1. Jump off
			draw_centered("Let's fly a little.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 133
			}

		case 133:
			draw_centered("It's impossible to die from a fall here.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 1330
			}

		case 1330:
			draw_centered("Because of dream.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 1331
			}

		case 1331:
			draw_centered(
				"In fact, you're immortal.\nBut what's the use of it when there's not a single living soul here besides you?",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 1332
			}

		case 1332:
			draw_centered("Only soulless particles and nothing more.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 1333
			}

		case 1333:
			draw_centered(":(", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 1334
			}

		case 1334:
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 134
			}


		case 134:
			draw_centered("I'm starting to doubt that this world has...", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 135
				rl.PlaySound(boom_edited)
				rl.StopMusicStream(falling)
			}

		case 135:
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 136
				rl.PlayMusicStream(music_stream)
				music_stream = chapter2
			}

		case 136:
			draw_centered("a floor.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 137
			}

		case 137:
			draw_centered("Ouch.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 138
			}

		case 138:
			draw_centered("I can't die from falling, but can feel it.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 139
			}

		case 139:
			draw_centered("And it's VERY HURT!", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				rl.PlaySound(stand_up_2)
				frames_counter = 0
				level = 200
			}

		// CHAPTER 2

		case 200:
			draw_centered("But, well.\nWhere a I?", frames_counter)
			action1("1. Look around")
			if rl.IsKeyPressed(.ONE) {
				frames_counter = 0
				level = 2001
			}

		case 2001:
			draw_centered(
				"Fortunately (or not), I can only see one door, very close to me.\nAnd it seems that there are some things there.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 201
			}

		case 201:
			draw_centered("Maybe there is some Particles?", frames_counter)
			action1("1. Enter the apartament")
			if rl.IsKeyPressed(.ONE) {
				frames_counter = 0
				rl.PlaySound(door_opened)
				level = 203
			}

		// case 202: long walk sound

		case 203:
			draw_centered(
				"It is a small but quite cozy apartment. Another oddity.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 2030
				frames_counter = 0
			}
		case 2030:
			draw_centered(
				"It's amazing to see such a thing\nin a world of endless piles and clutters. ",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 204
				frames_counter = 0
			}

		case 204:
			draw(
				"I see three rooms. One looks like a playroom,\nthe other is a bedroom,\nand the last is a kitchen.",
			)

			action1("1. Go to playroom")
			action2("2. Go to bedroom")
			action3("3. Go to kitchen")


			if rl.IsKeyPressed(.ONE) && skip_playroom == false && kitchen_key_taken == false {
				level = 210
				rl.PlaySound(walk_apartment)
				frames_counter = 0

			} else if rl.IsKeyPressed(.ONE) && photo_taken == true && kitchen_key_taken == false{
				level = 218
				rl.PlaySound(walk_apartment)
				frames_counter = 0

			} else if rl.IsKeyPressed(.ONE) && skip_playroom == true && kitchen_key_taken == false {
				level = 213
				rl.PlaySound(walk_apartment)
				frames_counter = 0
			} else if rl.IsKeyPressed(.ONE) && kitchen_key_taken == true && photo_taken == true {
				level = 2101
				frames_counter = 0
			}
			if rl.IsKeyPressed(.TWO) && diary_taken {
				rl.PlaySound(walk_apartment)
				frames_counter = 0
				level = 227 // go to bedroom (there is no diary now)
			} else if rl.IsKeyPressed(.TWO) && skip_diary2 == true {
				rl.PlaySound(walk_apartment)
				level = 224
				frames_counter = 0
			} else if rl.IsKeyPressed(.TWO) && skip_diary {
				rl.PlaySound(walk_apartment)
				level = 2200 // go to bedroom (skip description)
				frames_counter = 0
			} else if rl.IsKeyPressed(.TWO) && diary_taken == false {
				rl.PlaySound(walk_apartment)
				level = 220 // go to bedroom
				frames_counter = 0
			}
			if rl.IsKeyPressed(.THREE) {
				switch skip_kitchen {
				case true:
					rl.PlaySound(walk_apartment)
					level = 2301 // go to kitchen (skip description)
					frames_counter = 0
				case:
					rl.PlaySound(walk_apartment)
					level = 230 // go to kitchen
					frames_counter = 0
				}
			}

		case 2100:
			draw_centered(
				"It's the same room, but without the key on the ceiling.\nThere's a photograph on the table.",
				frames_counter,
			)
			action1("1. View a photo")
			if rl.IsKeyPressed(.ONE) {
				rl.PlaySound(photo_sound)
				level = 2140
				frames_counter = 0
			}
			action2("2. Go back")
			if rl.IsKeyPressed(.TWO) {
				rl.PlaySound(walk_apartment_2)
				level = 204
				frames_counter = 0
			}

		case 2101:
			draw_centered("There's nothing interesting here.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 204
				frames_counter = 0
			}

		case 210:
			// Go to playroom
			if photo_taken {
				rl.PlaySound(walk_apartment)
				level = 218
			} else if skip_playroom {
				rl.PlaySound(walk_apartment)
				level = 213
				frames_counter = 0
			} else if skip_photo {
				rl.PlaySound(walk_apartment)
				level = 216
				frames_counter = 0
			} else {
				draw_centered(
					"This room is very tiny: a bed, a table with a chair,\nand a strange ceiling.",
					frames_counter,
				)
				action_enter()
				if rl.IsKeyPressed(.ENTER) {
					level = 213
					frames_counter = 0
				}
			}

		case 213:
			draw_centered("There's a photograph on the table.", frames_counter)

			action1("1. View a photo")
			action2("2. Stare at the ceiling")
			action3("3. Go back")
			if rl.IsKeyPressed(.ONE) {
				rl.PlaySound(photo_sound)
				level = 2140
				frames_counter = 0
			}
			if rl.IsKeyPressed(.TWO) {
				level = 251
				frames_counter = 0
			}
			if rl.IsKeyPressed(.THREE) {
				rl.PlaySound(walk_apartment_2)
				level = 204
				frames_counter = 0
			}

		case 2140:
			draw_centered(
				"There's a someone on it. The picture doesn't change,\nwhich means it's very important to someone. ",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 215
				frames_counter = 0
			}

		case 215:
			draw_centered(
				"It's strange, but I feel something inside me\nwhen I look at it.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				skip_photo = true
				level = 216
				frames_counter = 0
			}

		case 216:
			draw_centered("Maybe I should take this photo.", frames_counter)

			action1("1. Put a picture in the backpack")
			action2("2. Go back")
			if rl.IsKeyPressed(.ONE) {
				level = 217
				photo_taken = true
				frames_counter = 0
				rl.PlaySound(backpack_sound)
			}
			if rl.IsKeyPressed(.TWO) {
				rl.PlaySound(walk_apartment_2)
				level = 204
			}

		case 217:
			draw_centered("A Photo is now in my collection.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				rl.PlaySound(walk_apartment_2)
				level = 204
			}

		case 218:
			draw_centered(
				"It's the same playroom with the strange ceiling,\nbut now without the photo on the table.",
				frames_counter,
			)
			action1("1. Stare at the ceiling")
			action2("2. Go back")
			if rl.IsKeyPressed(.ONE) {
				level = 251
				frames_counter = 0
			}
			if rl.IsKeyPressed(.TWO) {
				rl.PlaySound(walk_apartment_2)
				level = 204
				frames_counter = 0
			}

		case 220:
			draw_centered(
				"The bedroom has a double bed and only one bedside table.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				skip_diary = true
				level = 2200
				frames_counter = 0
			}

		case 2200:
			draw_centered("There's a diary.", frames_counter)
			action1("1. Read the diary")
			action2("2. Go back")
			if rl.IsKeyPressed(.ONE) {
				level = 221
				frames_counter = 0
				rl.PlaySound(diary_sound)
			}
			if rl.IsKeyPressed(.TWO) {
				rl.PlaySound(walk_apartment_2)
				level = 204
			}

		case 221:
			draw_centered(
				"Almost the entire text is blurred and changes its content.\nOnly one sentence remains in place:",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 222
				frames_counter = 0
			}

		case 222:
			draw_centered(
				"'The death of the body is not as terrible as the death of the soul:\nin the second case, the body remains an empty vessel that simply exists, \nwithout purpose and aspirations.'",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 223
				frames_counter = 0
			}

		case 223:
			switch photo_taken {
			case true:
				draw_centered(
					"Someone clearly had problems.\nAnd they're familiar to me. I feel something inside again.\nIt scares.",
					frames_counter,
				)
			case:
				// photo wasn't taken
				draw_centered(
					"Someone clearly had problems.\nAnd they're familiar to me. I feel something inside.\nIt scares.",
					frames_counter,
				)
			}
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				skip_diary2 = true
				level = 224
				frames_counter = 0
			}

		case 224:
			draw_centered("I can take this diary with me.", frames_counter)
			action1("1. Put the diary in the backpack")
			action2("2. Go back")
			if rl.IsKeyPressed(.ONE) {
				level = 225
				diary_taken = true
				frames_counter = 0
				rl.PlaySound(backpack_sound)
			}
			if rl.IsKeyPressed(.TWO) {
				rl.PlaySound(walk_apartment_2)
				level = 204
			}

		case 225:
			draw_centered("The Strange Diary is now in my collection.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 226
				frames_counter = 0
			}

		case 226:
			draw_centered("I hope I don't have to open it again.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				rl.PlaySound(walk_apartment_2)
				level = 204
			}

		case 227:
			draw_centered(
				"The same bedroom, but without the diary. There's nothing else interesting here.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				rl.PlaySound(walk_apartment_2)
				level = 204
			}

		case 230:
			// go to kitchen
			draw_centered("The kitchen is like a usual kitchen.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 2300
				frames_counter = 0
			}

		case 2300:
			draw_centered(
				"Refrigerator, microwave, lots of shelves, and of course...",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				skip_kitchen = true
				level = 2301
				frames_counter = 0
			}

		case 2301:
			draw_centered("There is the exit door.", frames_counter)
			action1("1. Open the door")
			action2("2. Go back")
			if rl.IsKeyPressed(.ONE) {
				switch kitchen_key_taken {
				case true:
					rl.PlaySound(door_opened)
					rl.StopMusicStream(chapter2)
					level = 2600
					frames_counter = 0
				case:
					rl.PlaySound(door_locked)
					level = 231
					frames_counter = 0

				}
			}
			if rl.IsKeyPressed(.TWO) {
				rl.PlaySound(walk_apartment_2)
				level = 204
			}

		case 231:
			// open the (exit) door
			// TODO: change to ENTER action
			draw_centered("Locked, of course.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 2310
				frames_counter = 0
			}

		case 2310:
			draw_centered("There must be a key somewhere in this apartment.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				rl.PlaySound(walk_apartment_2)
				level = 204
			}

		case 240:
			draw_centered("So, where is the key?", frames_counter)
			action1("1. Go to playroom")
			action2("2. Go to bedroom")
			action3("3. Go to kitchen")
			if rl.IsKeyPressed(.ONE) {
				rl.PlaySound(walk_apartment)
				level = 250
				frames_counter = 0

			}
			if rl.IsKeyPressed(.TWO) {
				rl.PlaySound(walk_apartment)
				level = 260
				frames_counter = 0
			}
			if rl.IsKeyPressed(.THREE) {
				rl.PlaySound(walk_apartment)
				level = 270
				frames_counter = 0
			}

		case 250:
			// go to playroom (after trying open exit door)
			draw(
				"Everything is still in place here. The eye only clings to the ceiling: it has a slightly different color than in the rest of the rooms.",
			)
			action1("1. Stare at the ceiling")
			if rl.IsKeyPressed(.ONE) {
				level = 251
				frames_counter = 0
			}

		case 251:
			// Stare at the ceiling
			draw_centered("This is a ceiling.\nNot good, but not bad", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 2510
				frames_counter = 0
			}


		case 2510:
			draw_centered("Oh. That's why the ceiling seemed so strange to me.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level += 1
				frames_counter = 0
			}

		case 2511:
			draw_centered("There is a key.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level += 1
				frames_counter = 0
			}


		case 2512:
			action_enter()
			draw_centered("On the Ceiling.", frames_counter)
			if rl.IsKeyPressed(.ENTER) {
				level += 1
				frames_counter = 0
			}

		case 2513:
			draw_centered("I need to get this key.", frames_counter)
			action1("1. Try to walk on the wall")
			action2("2. Go back")
			if rl.IsKeyPressed(.ONE) {
				level = 252
				frames_counter = 0
			}
			if rl.IsKeyPressed(.TWO) {
				skip_kitchen_description = true
				rl.PlaySound(walk_apartment_2)
				level = 204
			}

		case 252:
			//Try walking on the wall
			draw_rotated("Hmm, it's works.\nAlright.", frames_counter, rl.GetFontDefault()) //rotated/
			action1("1. Take the key")
			if rl.IsKeyPressed(.ONE) {
				level = 2520
				frames_counter = 0
				rl.PlaySound(key_taken)
			}

		case 2520:
			draw_rotated("There it is.", frames_counter, rl.GetFontDefault()) //rotated/
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 253
				frames_counter = 0
			}

		case 253:
			draw_rotated("Now it's time to go down.", frames_counter, rl.GetFontDefault()) //rotated/
			action1("1. Come down to floor")
			if rl.IsKeyPressed(.ONE) {
				level = 2530
				frames_counter = 0
				rl.PlaySound(walk_wall)
			}

		case 2530:
			draw_centered("Phew. It's much better this way.", frames_counter)

			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 2531
				frames_counter = 0
			}

		case 2531:
			draw_centered("I don't want to stand like this anymore.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 2532
				frames_counter = 0
			}

		case 2532:
			draw_centered("Never.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 204
				frames_counter = 0
				kitchen_key_taken = true
			}

		case 2533:
			draw_centered("Now i can open the exit door", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 204
				frames_counter = 0
			}

		case 260:
			draw("The kitchen is like a kitchen, but with the exit door.\n Now I can open it.")
			action1("1. Open the exit door")
			if rl.IsKeyPressed(.ONE) do level = 261

		case 2600:
			action_enter()
			draw_centered("...", frames_counter)
			if rl.IsKeyPressed(.ENTER) {
				level = 2610
				frames_counter = 0
			}

		case 261:
			draw_centered("Didn't I say that I would never walk on walls again?", frames_counter)

		case 2610:
			draw_centered("Didn't I say that I would never walk on walls again?", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 2611
				frames_counter = 0
			}

		case 2611:
			draw_centered("And it's true.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 2612
				frames_counter = 0
			}

		case 2612:
			draw_centered(
				"But now the whole world has been turned upside down here!",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 2613
				frames_counter = 0
			}


		case 2613:
			draw_centered("And here they are the only way.\nAgain...", frames_counter)
			action_enter()
			action1("1. Jump off!")
			if rl.IsKeyPressed(.ONE) {
				rl.PlayMusicStream(music_stream)
				music_stream = falling_inverted
				level = 262
				frames_counter = 0
			}

		case 2619:
			//TODO: -Inverted Jump-off sound. Wind "music"-
			action_enter()
			if rl.IsKeyPressed(.ENTER) do level = 262

		case 262:
			draw_centered("And now we fly in nowhere...", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 263
				frames_counter = 0
			}

		case 263:
			draw_centered(
				"A mysterious key is flying next to me too.\nBut from what?",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 264
				frames_counter = 0

			}

		case 264:
			draw_centered(
				"It looks like someone is tired of playing\nand wants to finish everything quickly,\ngiving all the aces.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 265
				frames_counter = 0
			}

		case 265:
			draw_centered("What a lazy creatures...", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 266
				frames_counter = 0
			}

		case 266:
			draw_centered("But it's for the best for me.", frames_counter)

			action1("1. Take the key")
			if rl.IsKeyPressed(.ONE) {
				level = 267
				frames_counter = 0
				rl.PlaySound(key_taken)
			}

		case 2660:
			action_enter()
			if rl.IsKeyPressed(.ENTER) do level = 267

		case 267:
			draw_centered("One more key in my endless pocket.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 268
				frames_counter = 0
			}

		case 268:
			draw_centered("I see the roof in the distance.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 269
				frames_counter = 0
			}

		case 269:
			draw_centered(
				"I wonder: how I ended up at the very beginning,\nwhen I was walking in the opposite direction?",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 270
				frames_counter = 0
			}

		case 270:
			draw_centered(
				"The landlord of this Universe clearly has problems with...",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				rl.PauseMusicStream(falling_inverted)
				rl.PlaySound(boom_edited)
				level = 2700
				frames_counter = 0
			}

		case 2700:
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 271
				frames_counter = 0
				music_stream = chapter3
				rl.PlayMusicStream(music_stream)
			}

		case 271:
			draw_centered("...orientation.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 2710
			}

		case 2710:
			draw_centered("Ouch...", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				rl.PlaySound(stand_up_2)
				frames_counter = 0
				level = 300
			}

		case 300:
			//Stand up
			draw_centered(
				"I went to the wall where I had woken up and turned to leave.\nSame door on the left, same door on the right.\n" +
				"The same exit to the outside.\nAnd the key in my backpack.",
				frames_counter,
			)
			action1("1. Open the door")
			if rl.IsKeyPressed(.ONE) {
				rl.PlaySound(door_opened_key)
				level = 3000
				frames_counter = 0
			}

		case 3000:
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				rl.PlaySound(door_opened)
				frames_counter = 0
				level = 3001
			}

		case 3001:
			// TODO: -walking sound-
			draw_centered("And there is a...", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 310
				frames_counter = 0
			}


		case 310:
			// Open the door
			draw_centered("Particle. But...", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 311
				frames_counter = 0
			}

		case 311:
			draw_particle(particle_texture)
			draw_under_picture("Alive Particle. A woman.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 312
			}

		case 312:
			draw_particle(particle_texture)
			draw_under_picture("She's standing in front of me.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 313
			}

		case 313:
			draw_particle(particle_texture)
			draw_under_picture(
				"This is the first time I've seen a Living Particle.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				frames_counter = 0
				level = 314
			}

		case 314:
			draw_particle(particle_texture)
			particle_under_picture("Welcome back", frames_counter, font)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 3140
				frames_counter = 0

			}
		case 3140:
			draw_particle(particle_texture)
			draw_under_picture("I never expected to see You here.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 320
				frames_counter = 0
			}

		case 320:
			draw_particle(particle_texture)
			particle_under_picture("But I'm here. And you are too.", frames_counter, font)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 3200
				frames_counter = 0
			}
		case 3200:
			draw_particle(particle_texture)
			draw_under_picture(
				"Why do I feel you like a particle, even though you're alive?",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 322
				frames_counter = 0
			}

		case 322:
			draw_particle(particle_texture)
			//Why do you feel like a particle even though you're alive?
			particle_under_picture(
				"You're wrong when you think of particles as things.",
				frames_counter,
				font,
			)

			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 323
				frames_counter = 0
			}

		case 323:
			draw_particle(particle_texture)
			particle_under_picture(
				"Particles are not things.\nThese are emotions. Feelings.",
				frames_counter,
				font,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 324
				frames_counter = 0
			}

		case 324:
			draw_particle(particle_texture)
			particle_under_picture(
				"These feelings come most strongly\nfrom other people.",
				frames_counter,
				font,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 325
				frames_counter = 0
			}

		case 325:
			draw_particle(particle_texture)
			particle_under_picture(
				"Family, friends, partner...\nthey all give their particles to their loved ones.",
				frames_counter,
				font,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 326
				frames_counter = 0
			}

		case 326:
			draw_particle(particle_texture)
			particle_under_picture(
				"Because otherwise the outside world\nwould be empty and cold.",
				frames_counter,
				font,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 327
				frames_counter = 0
			}

		case 327:
			draw_particle(particle_texture)
			particle_under_picture("Like yours.", frames_counter, font)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 3270
				frames_counter = 0
			}

		case 3270:
			draw_particle(particle_texture)
			draw_under_picture("Like.. My world?\nI don't understand.", frames_counter)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 330
				frames_counter = 0
			}

		case 330:
			draw_particle(particle_texture)
			particle_under_picture(
				"Yes. This is Your world around.\nSo huge.\nBut so empty.",
				frames_counter,
				font,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 331
				frames_counter = 0
			}

		case 331:
			draw_particle(particle_texture)
			particle_under_picture(
				"You've finally come back to your 'Self',\nbecause that's the only way you can be yourself again.",
				frames_counter,
				font,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 332
				frames_counter = 0
			}

		case 332:
			draw_particle(particle_texture)
			particle_under_picture(
				"All your endless collections of strangers particles\nare just garbage that you can never accept.",
				frames_counter,
				font,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 3320
				frames_counter = 0
			}

		case 3320:
			draw_particle(particle_texture)
			draw_under_picture(
				"I've been trying to pull myself together for so long,\nbut I still don't know what I'm doing wrong.",
				frames_counter,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 340
				frames_counter = 0
			}

		case 340:
			//I've been trying to pull myself together for so long, but I still don't understand what I'm doing wrong.
			draw_particle(particle_texture)
			particle_under_picture(
				"You were going the wrong way from the very beginning\nwhen you decided to 'Assemble' yourself.",
				frames_counter,
				font,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 341
				frames_counter = 0
			}

		case 341:
			draw_particle(particle_texture)
			particle_under_picture(
				"Particles are not endless combinations\nof what already exist.",
				frames_counter,
				font,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 342
				frames_counter = 0
			}

		case 342:
			draw_particle(particle_texture)
			particle_under_picture("This is the birth of a new one.", frames_counter, font)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 343
				frames_counter = 0
			}

		case 343:
			draw_particle(particle_texture)
			particle_under_picture("From the Inner World.", frames_counter, font)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 9990
				frames_counter = 0
			}


		// THE END	
		case 9990:
			particle_centered("Be yourself.", frames_counter, font)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level += 1
				frames_counter = 0
			}

		case 9991:
			particle_centered("Save you 'Self'.", frames_counter, font)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level += 1
				frames_counter = 0
			}

		case 9992:
			particle_centered(
				"Give your Particles to your loved ones\nAnd fill your World with them you love so much.",
				frames_counter,
				font,
			)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 9993
				frames_counter = 0
			}

		case 9993:
			particle_centered("Goodbye.", frames_counter, font)
			action_enter()
			if rl.IsKeyPressed(.ENTER) {
				level = 99980
				frames_counter = 0
			}


		case 99980:
			//TODO: -music of birth-
			action_enter()
			if rl.IsKeyPressed(.ENTER) do level = 9999


		case 9999:
			draw_static("Thanks for playing!")
			action_enter()
			if rl.IsKeyPressed(.ENTER) do level = 99990

		case 99990:
			draw_static("Press Escape to exit")

		// LORE

		case 9001:
			// Particles
			draw("")
			if rl.IsKeyPressed(.ENTER) do level = 006 // Back

		case 9002:
			// LandLord of Universe?
			draw("")
			if rl.IsKeyPressed(.ENTER) do level = 007 // Back

		case 9003:
			// Inner World?
			draw("Everyone has his own small Universe. Even Landlords of Universe have")
			if rl.IsKeyPressed(.ENTER) do level = 007 // Back

		case 9004:
			// Something?
			draw("Everyone has small Universe. Even Landlords of Universe have")
			if rl.IsKeyPressed(.ENTER) do level = 133 // Back
		}


		rl.EndMode2D()

		rl.EndDrawing()

		free_all(context.temp_allocator)

	}
}
