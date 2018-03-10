//
//  keyboardTranslation.m
//  Moonlight macOS
//
//  Created by Felix Kratz on 10.03.18.
//  Copyright © 2018 Felix Kratz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "keyboardTranslation.h"

CGKeyCode keyCharFromKeyCode(CGKeyCode keyCode) {
    // Proper key detection seems to want a switch statement, unfortunately
    switch (keyCode)
    {
        case 0: return 'A';
        case 1: return 'S';
        case 2: return 'D';
        case 3: return 'F';
        case 4: return 'H';
        case 5: return 'G';
        case 6: return 'Z';
        case 7: return 'X';
        case 8: return 'C';
        case 9: return 'V';
            // what is 10?
        case 11: return 'B';
        case 12: return 'Q';
        case 13: return 'W';
        case 14: return 'E';
        case 15: return 'R';
        case 16: return 'Y';
        case 17: return 'T';
        case 18: return '1';
        case 19: return '2';
        case 20: return '3';
        case 21: return '4';
        case 22: return '6';
        case 23: return '5';
        case 24: return '=';
        case 25: return '9';
        case 26: return '7';
        case 27: return '-';
        case 28: return '8';
        case 29: return '0';
        case 30: return ']';
        case 31: return 'O';
        case 32: return 'U';
        case 33: return '[';
        case 34: return 'I';
        case 35: return 'P';
        case 36: return 13; // ENTER
        case 37: return 'L';
        case 38: return 'J';
        case 39: return '\'';
        case 40: return 'K';
        case 41: return ';';
        case 42: return '\\';
        case 43: return ',';
        case 44: return '/';
        case 45: return 'N';
        case 46: return 'M';
       // case 47: return '.';
        case 48: return 9; // TAB
        case 49: return 32; // SPACE
        case 50: return '`';
        case 51: return 8; //BackSpace
        case 52: return 13; //ENTER
        case 53: return 27; //ESC
            
            // some more missing codes abound, reserved I presume, but it would
            // have been helpful for Apple to have a document with them all listed
            
        case 65: return '.';
            
        case 67: return '*';
            
        case 69: return '+';
            
        case 71: return 127; //Del
           
        //case 75: return @"/";
        //case 76: return @"ENTER";   // numberpad on full kbd
           
        case 78: return '-';
         /*
        case 81: return @"=";
        case 82: return '0';
        case 83: return '1';
        case 84: return '2';
        case 85: return '3';
        case 86: return @"4";
        case 87: return @"5";
        case 88: return @"6";
        case 89: return @"7";
            
        case 91: return @"8";
        case 92: return @"9";
            
        case 96: return @"F5";
        case 97: return @"F6";
        case 98: return @"F7";
        case 99: return @"F3";
        case 100: return @"F8";
        case 101: return @"F9";
            
        case 103: return @"F11";
            
        case 105: return @"F13";
            
        case 107: return @"F14";
            
        case 109: return @"F10";
            
        case 111: return @"F12";
            
        case 113: return @"F15";
        case 114: return @"HELP";
        case 115: return @"HOME";
        case 116: return @"PGUP";*/
        case 117: return 8;  // full keyboard right side numberpad
            /*
        case 118: return @"F4";
        case 119: return @"END";
        case 120: return @"F2";
        case 121: return @"PGDN";
        case 122: return @"F1";
        case 123: return @"LEFT";
        case 124: return @"RIGHT";
        case 125: return @"DOWN";
        case 126: return @"UP";*/
            
        default:
            
            return 0;
            // Unknown key, bail and note that RUI needs improvement
            //fprintf(stderr, "%ld\tKey\t%c (DEBUG: %d)\n", currenttime, keyCode;
            //exit(EXIT_FAILURE;
    }
}
