import java.util.LinkedList;
import java.util.Iterator;
import java.util.Deque;

boolean[] keysPressed = new boolean[128];
Player player;
AttackSequence currentSequence;
Sidebar sidebar;
int playerHP, invulnerability;
Menu menu, pausemenu;
GameState state;
GraphicsEngine sprites;
DialogueEngine dialogueEngine;

enum GameState {
  MENU, PLAY, PAUSED, DIALOGUE, OVER
}

void setup() {
  sprites = new GraphicsEngine();
  player = new Player();
  playerHP = 5;
  invulnerability = 60;
  menu = new MainMenu();
  pausemenu = new PauseMenu();
  state = GameState.DIALOGUE;
  currentSequence = new DemoSequence(width / 2, height / 2);
  dialogueEngine = new DialogueEngine();
  
  size(750, 750);
  sidebar = new Sidebar();
  noStroke();
}

void draw() {
  switch (state) {
    case MENU:
      menu.display();
      break;
    case PLAY:
      background(255);
      player.display();
      player.move();
      currentSequence.update();
      sidebar.display();
      if (--invulnerability < 0) { invulnerability = 0; }
      break;
    case OVER:
      background(255);
      fill(0);
      text("GAME OVER", 300, 300);
      break;
    case PAUSED:
      pausemenu.display();
      break;
    case DIALOGUE:
      background(255);
      player.display();
      sidebar.display();
      dialogueEngine.display();
      break;
      
  }
  text(frameRate, 20, height - 20);
  for (DemoButton b : sidebar.buttons) {
    b.display();
  }
}

void keyPressed() {
  switch (state) {
    case PLAY:
      if (keyCode == TAB) {
        state = GameState.PAUSED;
      }
      if (keyCode < keysPressed.length) {
        keysPressed[keyCode] = true;
      } else {
        println("warning: key is not within accepted range: " + keyCode);
      }
      break;
    case MENU:
      if (keyCode == UP) {
        menu.prev();
      }
      if (keyCode == DOWN) {
        menu.next();
      }
      if (keyCode == 'Z' || keyCode == ENTER) {
        menu.executeCurrent();
      }
      break;
    case PAUSED:
      if (keyCode == UP) {
        pausemenu.prev();
      }
      if (keyCode == DOWN) {
        pausemenu.next();
      }
      if (keyCode == 'Z' || keyCode == ENTER) {
        pausemenu.executeCurrent();
      }
      break;
    case OVER:
      //if any key pressed, reset (and return to title)
      setup();
    case DIALOGUE:
      //if any key pressed:
      if (dialogueEngine.hasNext()) {
        dialogueEngine.next(); //advance the dialogue
      } else {
        state = GameState.PLAY; //return to playing mode
      }
    default:
      break;
  }
}

void keyReleased() {
  switch (state) {
    case PLAY:
      if (keyCode < keysPressed.length) {
        keysPressed[keyCode] = false;
      } else {
        println("warning: key is not within accepted range: " + keyCode);
      }
     default:
       break;
  }
}

void mousePressed() {
  for (DemoButton button : sidebar.buttons) {
    if (button.mouseHovering()) {
      button.execute();
    }
  }
}

void triggerHit() {
  if (invulnerability == 0) {
    playerHP--;
    invulnerability = 60;
  }
  if (playerHP == 0) {
    state = GameState.OVER;
  }
}
