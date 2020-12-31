package castlevania3;

import java.awt.*;
import java.awt.image.*;
import java.io.*;
import javax.imageio.*;

public final class PasswordsImageGenerator {
       
    private static final int IMAGE_LEFT_MARGIN = 64;
    
    private static final int MATRIX_ELEMENT_SIZE = 24;
    
    private static final int MATRIX_LEFT_MARGIN = 4;
            
    private static final int MATRIX_TOP_MARGIN = 5;
    
    private static final int GLYPH_MARGIN = 2;
    
    private static final String[][] NAMES = {
        { "", "B", "C", "D", "E", "F", "G", "H", "HELP ME", "OKUDA", "URATA", "FUJIMOTO", },
        { "", "B", "C", "D", "E", "F", "G", "H", "HELP ME", "AKAMA", "AKAMA", "OKUDA", "URATA", "FUJIMOTO", },    
    };
    
    private static final int[][] MODES = {
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
        { 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, },
    };
        
    private static BufferedImage[] loadImages(final String... names) throws IOException {
        final BufferedImage[] images = new BufferedImage[names.length];
        for (int i = names.length - 1; i >= 0; --i) {
            images[i] = ImageIO.read(PasswordsImageGenerator.class.getResourceAsStream(
                    String.format("/castlevania3/images/%s.png", names[i])));
        }
        return images;
    }
    
    private static int computeMaxAgentHeight(final BufferedImage[] agentImages) {
        int maxHeight = 0;
        for (final BufferedImage image : agentImages) {
            maxHeight = Math.max(maxHeight, image.getHeight());
        }
        return maxHeight;
    }
    
    private static void renderAgents(final BufferedImage[][] agentImages, final BufferedImage[][] glyphImages,
            final BufferedImage matrixImage, final int y, final int maxAgentHeight, final Graphics2D g, 
            final int name, final int mode, final int partner, final int toggleMaskIndex) {
        
        final BufferedImage agentImage = agentImages[toggleMaskIndex][partner];
        final BufferedImage glyphImage = glyphImages[mode][name];
        
        final int glyphX = (IMAGE_LEFT_MARGIN - glyphImage.getWidth()) / 2;
        final int glyphY = (matrixImage.getHeight() - (maxAgentHeight + glyphImage.getHeight())) / 2 - GLYPH_MARGIN;
        g.drawImage(glyphImage, glyphX, y + glyphY, null);
        
        final int agentX = (IMAGE_LEFT_MARGIN - agentImage.getWidth()) / 2;
        final int agentY = matrixImage.getHeight() - 1 - glyphY - agentImage.getHeight();
        g.drawImage(agentImage, agentX, y + agentY, null);
    }
    
    private static void renderPassword(final int[][] password, final int x, final int y, final Graphics2D g, 
            final BufferedImage matrixImage, final BufferedImage[] markImages) {        
        g.drawImage(matrixImage, x, y, null);
        for (int i = password.length - 1; i >= 0; --i) {
            final int[] row = password[i];
            final int Y = y + MATRIX_TOP_MARGIN + i * MATRIX_ELEMENT_SIZE;
            for (int j = row.length - 1; j >= 0; --j) {
                final int mark = row[j];
                if (mark != Passwords.MARK_BLANK) {
                    g.drawImage(markImages[mark - 1], x + MATRIX_LEFT_MARGIN + j * MATRIX_ELEMENT_SIZE, Y, null);
                }                
            }
        }
    }
    
    public static void main(final String... args) throws IOException {
        
        final BufferedImage[] matrixImages = loadImages("matrix-0", "matrix-1");
        final BufferedImage[] markImages = loadImages("whip", "rosary", "heart");
        final BufferedImage[][] glyphImages = {
            loadImages("blank-w", "b-w", "c-w", "d-w", "e-w", "f-w", "g-w", "h-w", "help_me-w", "okuda-w", "urata-w", 
                    "fujimoto-w"),
            loadImages("blank-r", "b-r", "c-r", "d-r", "e-r", "f-r", "g-r", "h-r", "help_me-r", "akama-r", "akama-r",
                    "okuda-r", "urata-r", "fujimoto-r"),
        };
        final BufferedImage[][] agentImages = {
            loadImages("trevor-0", "sypha-0", "grant-0", "alucard-0"),
            loadImages("trevor-1", "sypha-1", "grant-1", "alucard-1"),
        };
        
        final int maxAgentHeight = computeMaxAgentHeight(agentImages[0]);
        
        final BufferedImage image = new BufferedImage(
                IMAGE_LEFT_MARGIN + Passwords.SAVE_POINTS.length * matrixImages[0].getWidth(),
                (MODES[0].length + MODES[1].length) * Passwords.TOGGLE_MASKS.length * Passwords.PARTNERS.length 
                        * matrixImages[0].getHeight(),
                BufferedImage.TYPE_INT_RGB);
        final Graphics2D g = image.createGraphics();        
        
        final int[][] password = new int[4][4];
        int row = 0;           
        int passwordCount = 0;        
        for (int i = 0; i < MODES.length; ++i) {
            for (int j = 0; j < MODES[i].length; ++j) {
                final int mode = MODES[i][j];
                final String name = NAMES[i][j];
                for (int toggleMaskIndex = 0; toggleMaskIndex < Passwords.TOGGLE_MASKS.length; ++toggleMaskIndex) {
                    for (int partner = 0; partner < Passwords.PARTNERS.length; ++partner) {                        
                        int x = IMAGE_LEFT_MARGIN;
                        final int y = row * matrixImages[0].getHeight();
                        renderAgents(agentImages, glyphImages, matrixImages[0], y, maxAgentHeight, g, j, i,
                                partner, toggleMaskIndex);
                        for (int savePoint = 0; savePoint < Passwords.SAVE_POINTS.length; ++savePoint) {
                            if (Passwords.isValidSavePoint(name, savePoint, partner, mode)) {
                                Passwords.encode(name, savePoint, partner, mode, toggleMaskIndex, 
                                        password);
                                renderPassword(password, x, y, g, matrixImages[(row & 1) ^ (savePoint & 1)], 
                                        markImages);
                                ++passwordCount;
                            }
                            x += matrixImages[0].getWidth();
                        }                        
                        ++row;
                    }
                }
            }
        }
        
        g.dispose();
        ImageIO.write(image, "png", new File("passwords.png"));
        
        System.out.format("Rendered %d passwords.%n", passwordCount);
    }
    
    private PasswordsImageGenerator() {        
    }
}