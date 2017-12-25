﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StandingState : IPlayerState {

	private static StandingState instance = null;

	public static StandingState Instance {
		get {
			if (instance == null) 
				instance = new StandingState ();
			
			return instance;
		}
	}

	public void handleInput(Player player) {

		if (Input.GetKey(KeyCode.A)) {
			player.turnLeft();
		}

		if (Input.GetKey(KeyCode.D)) {
			player.turnRight();
		}

		if (Input.GetKey (KeyCode.W)) {
			player.changeState (WalkingState.Instance);
			player.changeDirection (1);
			return;
		}

		if (Input.GetKey (KeyCode.S)) {
			player.changeState (WalkingState.Instance);
			player.changeDirection (-1);
			return;
		}

		if (Input.GetKeyDown (KeyCode.Space)) {
			player.Jump ();
			player.changeState (JumpingState.Instance);
		}
	}
}