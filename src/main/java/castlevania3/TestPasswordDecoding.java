package castlevania3;

public final class TestPasswordDecoding {
    
    private static final String[] NAMES 
            = { "", "B", "C", "D", "E", "F", "G", "H", "HELP ME", "AKAMA", "FUJIMOTO", "URATA", "OKUDA" };

    public static void main(final String... args) throws BadPasswordException {
        
        final int[][] password = new int[4][4];
        final GameState gameState = new GameState();
        for (int mode = 0; mode < Passwords.MODES.length; ++mode) {
            for (int name = 0; name < NAMES.length; ++name) {
                for (int toggleMaskIndex = 0; toggleMaskIndex < Passwords.TOGGLE_MASKS.length; ++toggleMaskIndex) {
                    for (int partner = 0; partner < Passwords.PARTNERS.length; ++partner) {                        
                        for (int savePoint = 0; savePoint < Passwords.SAVE_POINTS.length; ++savePoint) {
                            if (Passwords.isValidSavePoint(NAMES[name], savePoint, partner, mode)) {
                                Passwords.encode(NAMES[name], savePoint, partner, mode, toggleMaskIndex, password);
                                Passwords.decode(NAMES[name], password, gameState);
                                if (gameState.getMode() != mode
                                        || gameState.getPartner() != partner
                                        || gameState.getSavePoint() != savePoint
                                        || gameState.getToggleMaskIndex() != toggleMaskIndex) {
                                    throw new RuntimeException();
                                }
                            }
                        }                        
                    }
                }
            }
        }
    }
    
    private TestPasswordDecoding() {        
    }
}
