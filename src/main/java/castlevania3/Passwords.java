package castlevania3;

public final class Passwords {
       
    public static final String[] SAVE_POINTS = {
        "1-1 Warakiya Village - Skull Knight",                                                    // 0x00
        "2-1 Clock Tower of Untimely Death (climb up) - Nasty Grant",                             // 0x01
        "2-4 Clock Tower of Untimely Death (climb down to the Forest of Darkness)",               // 0x02 
        "3-0 Forest of Darkness (from the Warakiya Village) - Cyclops plus Sypha or Murky Marsh", // 0x03
        "3-1 Forest of Darkness (from the Clock Tower) - Cyclops plus Sypha or Murky Marsh",      // 0x04  
        "4-A Haunted Ship of Fools - Snake Man Sentinel and Death Fire (Mummies and Cyclops)",    // 0x05
        "5-A Tower of Terror - Frankenstein's Monster",                                           // 0x06
        "6-A Causeway of Chaos - Water Dragons",                                                  // 0x07  
        "4-1 Murky Marsh of Morbid Morons - Giant Bat",                                           // 0x08
        "5-1 Caves (entering) - Alucard",                                                         // 0x09
        "5-6 Caves (escaping) - Skull Knight King or Sunken City",                                // 0x0A
        "6-1 Sunken City of Poltergeists - Bone Dragon King",                                     // 0x0B
        "6-1 Castle Basement - Frankenstein's Monster",                                           // 0x0C
        "7-1 Morbid Mountains - Giant Bat and Death Fire King (Mummies, Cyclops, and Leviathan)", // 0x0D
        "7-A Rampart and Lookout Tower - Death Fire King (Mummies, Cyclops, and Leviathan)",      // 0x0E
        "8-1 Castle Entrance - Grim Reaper",                                                      // 0x0F
        "9-1 Villa and Waterfalls - Doppelgänger",                                                // 0x10
        "A-1 Clock Tower and Castle Keep - Dracula",                                              // 0x11
    };
       
    public static final String[] PARTNERS = {
        "none",           // 0
        "Sypha Belnades", // 1
        "Grant Danasty",  // 2
        "Alucard",        // 3
    };
    
    public static final int[] TOGGLE_MASKS = {
        0x55, // 0 - even bits
        0xAA, // 1 - odd bits
    };
    
    // 03:B8B6 - valid save points for each partner
    private static final int[] VALID_SAVE_POINT_BITS = { 0xFF_FF_FF, 0x07_03_FF, 0x2F_FF_FF, 0x00_3D_FF, };
    
    private static final boolean[][] VALID_SAVE_POINTS = new boolean[PARTNERS.length][SAVE_POINTS.length];
    
    static {
        for (int partner = PARTNERS.length - 1; partner >= 0; --partner) {
            for (int savePoint = SAVE_POINTS.length - 1; savePoint >= 0; --savePoint) {
                VALID_SAVE_POINTS[partner][savePoint] = (VALID_SAVE_POINT_BITS[partner] 
                        & (0x80_00_00 >> savePoint)) != 0;
            }
        }
    }
    
    public static final int MARK_BLANK = 0;
    public static final int MARK_WHIP = 1;
    public static final int MARK_ROSERY = 2;
    public static final int MARK_HEART = 3;
    
    private static final char[] MARK_NAMES = { '.', 'W', 'R', 'H' };
    
    // 03:B6B2 - scramble sequences
    private static final int[][] SCRAMBLES = {
        { 0x00, 0x33, 0x20, 0x13, 0x22, 0x01, 0x11, 0x03, 0x32, },
        { 0x12, 0x10, 0x02, 0x32, 0x23, 0x13, 0x30, 0x21, 0x01, },
        { 0x31, 0x13, 0x01, 0x22, 0x10, 0x30, 0x33, 0x03, 0x21, },
    };
        
    // 03:B937 - scramble sequence selectors
    private static final int[] SELECTORS = { 0x01, 0x1B, 0x02, 0x35, 0x19, 0x03, 0x37, 0x1A, 0x36, };
        
    public static final int MODE_NORMAL = 0;
    public static final int MODE_HARD = 1;
    
    public static final int[] MODES = {
        MODE_NORMAL, // 0
        MODE_HARD,   // 1
    };
    
    public static final String[] MODE_NAMES = {
        "Normal", // 0
        "Hard",   // 1
    };    
    
    // 03:B6E6 - sum of the elements
    private static final int NAME_HASH_SEED = 28;
    
    // glyph tile indices from the Pattern Table
    private static final int TILE_SPACE = 0x00;
    private static final int TILE_PERIOD = 0x4B;
    private static final int TILE_A = 0x50;
    private static final int TILE_EXCLAMATION_MARK = 0x6A;
    private static final int TILE_QUESTION_MARK = 0x6B;
    
    private static boolean isSpecialName(final String name) {
        switch(name) {
            case "AKAMA":
            case "FUJIMOTO":
            case "URATA":
            case "OKUDA":
                return true;
            default:
                return false;
        }
    }    
    
    public static boolean isValidSavePoint(final String name, final int savePoint, final int partner, final int mode) {
        return (mode == MODE_HARD) || VALID_SAVE_POINTS[partner][savePoint] || isSpecialName(name);
    }
    
    private static int toMark(final char markName) {
        switch(Character.toUpperCase(markName)) {
            case 'W':
                return MARK_WHIP;
            case 'R':
                return MARK_ROSERY;
            case 'H':
                return MARK_HEART;
            default:
                return MARK_BLANK;
        }
    }
    
    private static char toMarkName(final int mark) {
        return MARK_NAMES[mark];
    }
    
    private static int toTile(final char c) {
        switch(c) {
            case ' ':
                return TILE_SPACE;
            case '.':
                return TILE_PERIOD;
            case '!':
                return TILE_EXCLAMATION_MARK;
            case '?':
                return TILE_QUESTION_MARK;
            default:
                if (c >= 'A' && c <= 'Z') {
                    return c - 'A' + TILE_A;
                }
                throw new RuntimeException("Invalid character.");
        }
    }
    
    private static int hashName(final String name) {
        int nameHash = NAME_HASH_SEED;
        for (int i = name.length() - 1; i >= 0; --i) {
            nameHash += toTile(name.charAt(i));
        }
        return nameHash & 7;
    }
    
    private static int encodePayload(final String name, final int savePoint, final int partner, 
            final int mode, final int toggleMaskIndex) {
        return (hashName(name) << 5) | ((savePoint & 1) << 4) | (toggleMaskIndex << 3) | (partner << 1) | mode;
    }
       
    private static int hashPayload(final int payload, final int savePoint, final int toggleMaskIndex) {
        
        final int nibbleSum = 0x0F & ((payload >> 4) + payload);
        
        final int toggledPayload = TOGGLE_MASKS[toggleMaskIndex] ^ payload;
        final int toggledNibbleSum = 0x0F & ((toggledPayload >> 4) + toggledPayload);
        
        final int sums = (nibbleSum << 4) | toggledNibbleSum;
        
        return 0xFF & (savePoint + sums);
    }
    
    private static void clearPassword(final int[][] password) {
        for (int i = password.length - 1; i >= 0; --i) {
            final int[] row = password[i];
            for (int j = row.length - 1; j >= 0; --j) {
                row[j] = MARK_BLANK;
            }
        }
    }
    
    public static int[][] encode(final String name, final int savePoint, final int partner, final int mode, 
            final int toggleMaskIndex) {        
        final int[][] password = new int[4][4];
        encode(name, savePoint, partner, mode, toggleMaskIndex, password);
        return password;
    }
    
    public static int[][] encode(final GameState gameState) {
        final int[][] password = new int[4][4];
        encode(gameState, password);
        return password;
    }
    
    public static void encode(final GameState gameState, final int[][] password) {
        encode(gameState.getName(), gameState.getSavePoint(), gameState.getPartner(), gameState.getMode(),
                gameState.getToggleMaskIndex(), password);
    }
    
    public static void encode(final String name, final int savePoint, final int partner, final int mode, 
            final int toggleMaskIndex, final int[][] password) {
        
        clearPassword(password);    
        
        final int selector = SELECTORS[savePoint >> 1];
        final int selectorRowCol = (0x30 & selector) | (0x03 & (selector >> 2));
        int[] scrambles = null;
        for (int i = SCRAMBLES.length - 1; i >= 0; --i) {
            scrambles = SCRAMBLES[i];
            if (scrambles[0] == selectorRowCol) {
                break;
            }
        }
        
        final int payload = encodePayload(name, savePoint, partner, mode, toggleMaskIndex);
        final int payloadHash = hashPayload(payload, savePoint, toggleMaskIndex);
        
        for (int i = scrambles.length - 1; i >= 0; --i) {            
            final int row = scrambles[i] >> 4;
            final int col = scrambles[i] & 0x03;
            password[row][col] = (i == 0) 
                    ? (selector & 3) 
                    : (((payload >> (i - 1)) & 1) << 1) | ((payloadHash >> (i - 1)) & 1);
        }
    }
    
    private static int[] findScrambles(final int[][] password) throws BadPasswordException {
        
        int[] scrambles = null;        
        for (int i = SCRAMBLES.length - 1; i >= 0; --i) {
            final int rowCol = SCRAMBLES[i][0];
            if (password[rowCol >> 4][rowCol & 0x03] != MARK_BLANK) {
                if (scrambles == null) {
                    scrambles = SCRAMBLES[i];
                } else {
                    throw new BadPasswordException();
                }
            }
        }
        
        if (scrambles == null) {
            throw new BadPasswordException();
        }
        
        return scrambles;
    }
    
    private static int findSelectorIndex(final int[][] password, final int[] scrambles) {
        final int rowCol = scrambles[0];
        final int selector = (rowCol & 0x30) | ((rowCol & 0x03) << 2) | password[rowCol >> 4][rowCol & 0x03];
        int selectorIndex = SELECTORS.length - 1;
        while (SELECTORS[selectorIndex] != selector && selectorIndex > 0) {
            --selectorIndex;
        }
        return selectorIndex;
    }
       
    private static void verifyAllNonblanksInScrambles(final int[][] password, final int[] scrambles) 
            throws BadPasswordException {
        
        for (int row = password.length - 1; row >= 0; --row) {
            final int[] passwordRow = password[row];
            middle: for (int col = passwordRow.length - 1; col >= 0; --col) {
                final int mark = passwordRow[col];
                if (mark != MARK_BLANK) {
                    for (int k = scrambles.length - 1; k >= 0; --k) {
                        if (row == (scrambles[k] >> 4) && col == (scrambles[k] & 0x03)) {
                            continue middle;
                        }                        
                    }
                    throw new BadPasswordException();
                }
            }
        }
    }
    
    private static int decodePayload(final int[][] password, final int[] scrambles) {
        return decodeData(password, scrambles, 1);
    }
    
    private static int decodePayloadHash(final int[][] password, final int[] scrambles) {
        return decodeData(password, scrambles, 0);
    }    
    
    private static int decodeData(final int[][] password, final int[] scrambles, final int shift) {
        int data = 0;
        for (int i = scrambles.length - 1; i > 0; --i) {
            final int rowCol = scrambles[i];
            data = (data << 1) | ((password[rowCol >> 4][rowCol & 0x03] >> shift) & 1);
        }
        return data;
    }    
    
    public static GameState decode(final String name, final int[][] password) throws BadPasswordException {
        final GameState gameState = new GameState();
        decode(name, password, gameState);
        return gameState;
    }
    
    public static void decode(final String name, final int[][] password, GameState gameState) 
            throws BadPasswordException {
        
        final int[] scrambles = findScrambles(password);
        final int selectorIndex = findSelectorIndex(password, scrambles);
        verifyAllNonblanksInScrambles(password, scrambles);
        
        final int state = decodePayload(password, scrambles);        
        final int nameHash = state >> 5;
        final int savePoint = (selectorIndex << 1) | ((state >> 4) & 1);
        final int toggleMaskIndex = (state >> 3) & 1;
        final int partner = (state >> 1) & 3;
        final int mode = state & 1;
                
        if (!isValidSavePoint(name, savePoint, partner, mode)
                || hashName(name) != nameHash
                || hashPayload(state, savePoint, toggleMaskIndex) != decodePayloadHash(password, scrambles)) {
            throw new BadPasswordException();
        }

        gameState.setMode(mode);
        gameState.setName(name);
        gameState.setPartner(partner);
        gameState.setSavePoint(savePoint);
        gameState.setToggleMaskIndex(toggleMaskIndex);
    }
    
    public static void print(final int[][] password) {
        for (int row = 0; row < password.length; ++row) {            
            final int[] passwordRow = password[row];
            final StringBuilder sb = new StringBuilder();
            for (int col = 0; col < passwordRow.length; ++col) {
                if (sb.length() > 0) {
                    sb.append(' ');
                }
                sb.append(toMarkName(passwordRow[col]));
            }
            System.out.println(sb);
        }
    }
    
    public static int[][] parse(final char[][] password) {
        final int[][] parsed = new int[4][4];
        parse(password, parsed);
        return parsed;
    }
    
    public static void parse(final char[][] password, final int[][] parsed) {
        for (int i = password.length - 1; i >= 0; --i) {
            final char[] passwordRow = password[i];
            final int[] parsedRow = parsed[i];
            for (int j = passwordRow.length - 1; j >= 0; --j) {
                parsedRow[j] = toMark(passwordRow[j]);
            }
        }
    }

    public static int[][] parse(final String[] password) {
        final int[][] parsed = new int[4][4];
        parse(password, parsed);
        return parsed;
    }
    
    public static void parse(final String[] password, final int[][] parsed) {
        for (int i = password.length - 1; i >= 0; --i) {
            final String passwordRow = password[i];
            final int[] parsedRow = parsed[i];
            for (int j = passwordRow.length() - 1; j >= 0; --j) {
                parsedRow[j] = toMark(passwordRow.charAt(j));
            }
        }
    }

    public static int[][] parse(final String password) {
        final int[][] parsed = new int[4][4];
        parse(password, parsed);
        return parsed;
    }
    
    public static void parse(final String password, final int[][] parsed) {
        for (int i = parsed.length - 1; i >= 0; --i) {
            final int[] parsedRow = parsed[i];
            for (int j = parsed.length - 1; j >= 0; --j) {
                parsedRow[j] = toMark(password.charAt((i << 2) | j));
            }
        }
    }    
    
    private Passwords() {        
    }
}
