package castlevania3;

public class GameState {

    private String name;
    private int savePoint;
    private int partner;
    private int mode;
    private int toggleMaskIndex;

    public String getName() {
        return name;
    }

    public void setName(final String name) {
        this.name = name;
    }

    public int getSavePoint() {
        return savePoint;
    }

    public void setSavePoint(final int savePoint) {
        this.savePoint = savePoint;
    }

    public int getPartner() {
        return partner;
    }

    public void setPartner(final int partner) {
        this.partner = partner;
    }

    public int getMode() {
        return mode;
    }

    public void setMode(final int mode) {
        this.mode = mode;
    }

    public int getToggleMaskIndex() {
        return toggleMaskIndex;
    }

    public void setToggleMaskIndex(final int toggleMaskIndex) {
        this.toggleMaskIndex = toggleMaskIndex;
    }
    
    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder();
        sb.append(String.format("           name: %s%n", name));
        sb.append(String.format("      savePoint: %s%n", Passwords.SAVE_POINTS[savePoint]));        
        sb.append(String.format("        partner: %s%n", Passwords.PARTNERS[partner]));
        sb.append(String.format("           mode: %s%n", Passwords.MODE_NAMES[mode]));
        sb.append(String.format("toggleMaskIndex: %d%n", toggleMaskIndex));
        return sb.toString();
    }
}
