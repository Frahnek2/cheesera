/// Registry of official Fujifilm LUT assets
/// 
/// This file contains a comprehensive list of all Fujifilm LUTs organized by
/// camera profile type (F-Log, F-Log2, Standard) and their target transformations.
class LutRegistry {
  /// Profile types supported by the LUT system
  static const String profileFLog = 'flog';
  static const String profileFLog2 = 'flog2';
  static const String profileFLog2C = 'flog2c';
  static const String profileStandard = 'standard';

  /// Target transformations
  static const String targetEterna = 'eterna';
  static const String targetEternaBB = 'eterna_bb';
  static const String targetFLog = 'flog';
  static const String targetWDR = 'wdr';
  static const String targetRec709 = 'rec709';
  static const String targetAcros = 'acros';
  static const String targetAstia = 'astia';
  static const String targetClassicChrome = 'classic_chrome';
  static const String targetClassicNeg = 'classic_neg';
  static const String targetProvia = 'provia';
  static const String targetProNegStd = 'pro_neg_std';
  static const String targetRealaAce = 'reala_ace';
  static const String targetVelvia = 'velvia';

  /// All available LUTs organized by profile type
  static const Map<String, List<LutInfo>> lutsByProfile = {
    profileFLog: [
      // GFX100
      LutInfo(
        assetPath: 'assets/luts/flog/gfx100_flog_fgamut_to_eterna_bb_bt.709_33grid_v.1.01.cube',
        camera: 'GFX100',
        profile: profileFLog,
        target: targetEternaBB,
        displayName: 'GFX100 F-Log to Eterna Bleach Bypass',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/gfx100_flog_fgamut_to_eterna_bt.709_33grid_v.1.01.cube',
        camera: 'GFX100',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'GFX100 F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/gfx100_flog_fgamut_to_flog_bt.709_33grid_v.1.01.cube',
        camera: 'GFX100',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'GFX100 F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/gfx100_flog_fgamut_to_wdr_bt.709_33grid_v.1.01.cube',
        camera: 'GFX100',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'GFX100 F-Log to WDR',
      ),
      // GFX100S
      LutInfo(
        assetPath: 'assets/luts/flog/gfx100s_flog_fgamut_to_eterna_bb_bt.709_33grid_v.1.01.cube',
        camera: 'GFX100S',
        profile: profileFLog,
        target: targetEternaBB,
        displayName: 'GFX100S F-Log to Eterna Bleach Bypass',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/gfx100s_flog_fgamut_to_eterna_bt.709_33grid_v.1.01.cube',
        camera: 'GFX100S',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'GFX100S F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/gfx100s_flog_fgamut_to_flog_bt.709_33grid_v.1.01.cube',
        camera: 'GFX100S',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'GFX100S F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/gfx100s_flog_fgamut_to_wdr_bt.709_33grid_v.1.01.cube',
        camera: 'GFX100S',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'GFX100S F-Log to WDR',
      ),
      // X100V
      LutInfo(
        assetPath: 'assets/luts/flog/x100v_flog_fgamut_to_eterna_bt.709_33grid_v.1.01.cube',
        camera: 'X100V',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'X100V F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/x100v_flog_fgamut_to_flog_bt.709_33grid_v.1.01.cube',
        camera: 'X100V',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'X100V F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/x100v_flog_fgamut_to_wdr_bt.709_33grid_v.1.01.cube',
        camera: 'X100V',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'X100V F-Log to WDR',
      ),
      // X-E4
      LutInfo(
        assetPath: 'assets/luts/flog/xe4_flog_fgamut_to_eterna_bb_bt.709_33grid_v.1.01.cube',
        camera: 'X-E4',
        profile: profileFLog,
        target: targetEternaBB,
        displayName: 'X-E4 F-Log to Eterna Bleach Bypass',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xe4_flog_fgamut_to_eterna_bt.709_33grid_v.1.01.cube',
        camera: 'X-E4',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'X-E4 F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xe4_flog_fgamut_to_flog_bt.709_33grid_v.1.01.cube',
        camera: 'X-E4',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'X-E4 F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xe4_flog_fgamut_to_wdr_bt.709_33grid_v.1.01.cube',
        camera: 'X-E4',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'X-E4 F-Log to WDR',
      ),
      // X-H1
      LutInfo(
        assetPath: 'assets/luts/flog/xh1_flog_fgamut_to_eterna_bt.709_33grid_v.1.01.cube',
        camera: 'X-H1',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'X-H1 F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xh1_flog_fgamut_to_flog_bt.709_33grid_v.1.01.cube',
        camera: 'X-H1',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'X-H1 F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xh1_flog_fgamut_to_wdr_bt.709_33grid_v.1.01.cube',
        camera: 'X-H1',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'X-H1 F-Log to WDR',
      ),
      // X-H2
      LutInfo(
        assetPath: 'assets/luts/flog/xh2_flog_fgamut_to_eterna_bb_bt.709_33gird_v.1.00.cube',
        camera: 'X-H2',
        profile: profileFLog,
        target: targetEternaBB,
        displayName: 'X-H2 F-Log to Eterna Bleach Bypass',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xh2_flog_fgamut_to_eterna_bt.709_33grid_v.1.00.cube',
        camera: 'X-H2',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'X-H2 F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xh2_flog_fgamut_to_flog_bt.709_33grid_v.1.00.cube',
        camera: 'X-H2',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'X-H2 F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xh2_flog_fgamut_to_wdr_bt.709_33grid_v.1.00.cube',
        camera: 'X-H2',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'X-H2 F-Log to WDR',
      ),
      // X-H2S
      LutInfo(
        assetPath: 'assets/luts/flog/xh2s_flog_fgamut_to_eterna_bb_bt.709_33gird_v.1.00.cube',
        camera: 'X-H2S',
        profile: profileFLog,
        target: targetEternaBB,
        displayName: 'X-H2S F-Log to Eterna Bleach Bypass',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xh2s_flog_fgamut_to_eterna_bt.709_33grid_v.1.00.cube',
        camera: 'X-H2S',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'X-H2S F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xh2s_flog_fgamut_to_flog_bt.709_33grid_v.1.00.cube',
        camera: 'X-H2S',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'X-H2S F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xh2s_flog_fgamut_to_wdr_bt.709_33grid_v.1.00.cube',
        camera: 'X-H2S',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'X-H2S F-Log to WDR',
      ),
      // X-Pro3
      LutInfo(
        assetPath: 'assets/luts/flog/xpro3_flog_fgamut_to_eterna_bt.709_33grid_v.1.01.cube',
        camera: 'X-Pro3',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'X-Pro3 F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xpro3_flog_fgamut_to_flog_bt.709_33grid_v.1.01.cube',
        camera: 'X-Pro3',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'X-Pro3 F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xpro3_flog_fgamut_to_wdr_bt.709_33grid_v.1.01.cube',
        camera: 'X-Pro3',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'X-Pro3 F-Log to WDR',
      ),
      // X-S10
      LutInfo(
        assetPath: 'assets/luts/flog/xs10_flog_fgamut_to_eterna_bb_bt.709_33grid_v.1.01.cube',
        camera: 'X-S10',
        profile: profileFLog,
        target: targetEternaBB,
        displayName: 'X-S10 F-Log to Eterna Bleach Bypass',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xs10_flog_fgamut_to_eterna_bt.709_33grid_v.1.01.cube',
        camera: 'X-S10',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'X-S10 F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xs10_flog_fgamut_to_flog_bt.709_33grid_v.1.01.cube',
        camera: 'X-S10',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'X-S10 F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xs10_flog_fgamut_to_wdr_bt.709_33grid_v.1.01.cube',
        camera: 'X-S10',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'X-S10 F-Log to WDR',
      ),
      // X-T2
      LutInfo(
        assetPath: 'assets/luts/flog/xt2_flog_fgamut_to_eterna_bt.709_33grid_v.1.01.cube',
        camera: 'X-T2',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'X-T2 F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xt2_flog_fgamut_to_flog_bt.709_33grid_v.1.01.cube',
        camera: 'X-T2',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'X-T2 F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xt2_flog_fgamut_to_wdr_bt.709_33grid_v.1.01.cube',
        camera: 'X-T2',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'X-T2 F-Log to WDR',
      ),
      // X-T30
      LutInfo(
        assetPath: 'assets/luts/flog/xt30_flog_fgamut_to_eterna_bt.709_33grid_v.1.01.cube',
        camera: 'X-T30',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'X-T30 F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xt30_flog_fgamut_to_flog_bt.709_33grid_v.1.01.cube',
        camera: 'X-T30',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'X-T30 F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xt30_flog_fgamut_to_wdr_bt.709_33grid_v.1.01.cube',
        camera: 'X-T30',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'X-T30 F-Log to WDR',
      ),
      // X-T30II
      LutInfo(
        assetPath: 'assets/luts/flog/xt30ii_flog_fgamut_to_eterna_bb_bt.709_33grid_v.1.01.cube',
        camera: 'X-T30II',
        profile: profileFLog,
        target: targetEternaBB,
        displayName: 'X-T30II F-Log to Eterna Bleach Bypass',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xt30ii_flog_fgamut_to_eterna_bt.709_33grid_v.1.01.cube',
        camera: 'X-T30II',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'X-T30II F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xt30ii_flog_fgamut_to_flog_bt.709_33grid_v.1.01.cube',
        camera: 'X-T30II',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'X-T30II F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xt30ii_flog_fgamut_to_wdr_bt.709_33grid_v.1.01.cube',
        camera: 'X-T30II',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'X-T30II F-Log to WDR',
      ),
      // X-T3
      LutInfo(
        assetPath: 'assets/luts/flog/xt3_flog_fgamut_to_eterna_bt.709_33grid_v.1.01.cube',
        camera: 'X-T3',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'X-T3 F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xt3_flog_fgamut_to_flog_bt.709_33grid_v.1.01.cube',
        camera: 'X-T3',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'X-T3 F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xt3_flog_fgamut_to_wdr_bt.709_33grid_v.1.01.cube',
        camera: 'X-T3',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'X-T3 F-Log to WDR',
      ),
      // X-T4
      LutInfo(
        assetPath: 'assets/luts/flog/xt4_flog_fgamut_to_eterna_bb_bt.709_33grid_v.1.01.cube',
        camera: 'X-T4',
        profile: profileFLog,
        target: targetEternaBB,
        displayName: 'X-T4 F-Log to Eterna Bleach Bypass',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xt4_flog_fgamut_to_eterna_bt.709_33grid_v.1.01.cube',
        camera: 'X-T4',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'X-T4 F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xt4_flog_fgamut_to_flog_bt.709_33grid_v.1.01.cube',
        camera: 'X-T4',
        profile: profileFLog,
        target: targetFLog,
        displayName: 'X-T4 F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog/xt4_flog_fgamut_to_wdr_bt.709_33grid_v.1.01.cube',
        camera: 'X-T4',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'X-T4 F-Log to WDR',
      ),
    ],
    profileFLog2: [
      // F-Log2 LUTs
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2_to_acros_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2,
        target: targetAcros,
        displayName: 'F-Log2 to Acros',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2_to_astia_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2,
        target: targetAstia,
        displayName: 'F-Log2 to Astia',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2_to_classic_chrome_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2,
        target: targetClassicChrome,
        displayName: 'F-Log2 to Classic Chrome',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2_to_classic_neg._33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2,
        target: targetClassicNeg,
        displayName: 'F-Log2 to Classic Negative',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2_to_eterna_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2,
        target: targetEterna,
        displayName: 'F-Log2 to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2_to_eterna_bb_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2,
        target: targetEternaBB,
        displayName: 'F-Log2 to Eterna Bleach Bypass',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2_to_flog2_709_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2,
        target: targetRec709,
        displayName: 'F-Log2 to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2_to_pro_neg.std_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2,
        target: targetProNegStd,
        displayName: 'F-Log2 to Pro Neg. Std',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2_to_provia_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2,
        target: targetProvia,
        displayName: 'F-Log2 to Provia',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2_to_reala_ace_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2,
        target: targetRealaAce,
        displayName: 'F-Log2 to Reala ACE',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2_to_velvia_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2,
        target: targetVelvia,
        displayName: 'F-Log2 to Velvia',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2_to_wdr_709_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2,
        target: targetWDR,
        displayName: 'F-Log2 to WDR',
      ),
      // F-Log2C LUTs
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2c_to_acros_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2C,
        target: targetAcros,
        displayName: 'F-Log2C to Acros',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2c_to_astia_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2C,
        target: targetAstia,
        displayName: 'F-Log2C to Astia',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2c_to_classic_chrome_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2C,
        target: targetClassicChrome,
        displayName: 'F-Log2C to Classic Chrome',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2c_to_classic_neg._33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2C,
        target: targetClassicNeg,
        displayName: 'F-Log2C to Classic Negative',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2c_to_eterna_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2C,
        target: targetEterna,
        displayName: 'F-Log2C to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2c_to_eterna_bb_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2C,
        target: targetEternaBB,
        displayName: 'F-Log2C to Eterna Bleach Bypass',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2c_to_flog2c_709_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2C,
        target: targetRec709,
        displayName: 'F-Log2C to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2c_to_pro_neg.std_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2C,
        target: targetProNegStd,
        displayName: 'F-Log2C to Pro Neg. Std',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2c_to_provia_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2C,
        target: targetProvia,
        displayName: 'F-Log2C to Provia',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2c_to_reala_ace_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2C,
        target: targetRealaAce,
        displayName: 'F-Log2C to Reala ACE',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2c_to_velvia_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog2C,
        target: targetVelvia,
        displayName: 'F-Log2C to Velvia',
      ),
      LutInfo(
        assetPath: 'assets/luts/flog2/flog2c_to_wdr_709_33grid_v.1.10.cube',
        camera: 'GFX',
        profile: profileFLog2C,
        target: targetWDR,
        displayName: 'F-Log2C to WDR',
      ),
    ],
    profileStandard: [
      LutInfo(
        assetPath: 'assets/luts/standard/flog_to_wdr_709_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog,
        target: targetWDR,
        displayName: 'F-Log to WDR',
      ),
      LutInfo(
        assetPath: 'assets/luts/standard/flog_to_eterna_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog,
        target: targetEterna,
        displayName: 'F-Log to Eterna',
      ),
      LutInfo(
        assetPath: 'assets/luts/standard/flog_to_flog_709_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog,
        target: targetRec709,
        displayName: 'F-Log to Rec.709',
      ),
      LutInfo(
        assetPath: 'assets/luts/standard/flog_to_eterna_bb_33grid_v.1.00.cube',
        camera: 'GFX',
        profile: profileFLog,
        target: targetEternaBB,
        displayName: 'F-Log to Eterna Bleach Bypass',
      ),
    ],
  };

  /// Get all LUTs for a specific profile type
  static List<LutInfo> getLutsByProfile(String profile) {
    return lutsByProfile[profile] ?? [];
  }

  /// Get all LUTs for a specific target transformation
  static List<LutInfo> getLutsByTarget(String target) {
    List<LutInfo> result = [];
    for (var luts in lutsByProfile.values) {
      result.addAll(luts.where((lut) => lut.target == target));
    }
    return result;
  }

  /// Get all LUTs for a specific camera
  static List<LutInfo> getLutsByCamera(String camera) {
    List<LutInfo> result = [];
    for (var luts in lutsByProfile.values) {
      result.addAll(luts.where((lut) => lut.camera == camera));
    }
    return result;
  }

  /// Get a flat list of all LUTs
  static List<LutInfo> getAllLuts() {
    List<LutInfo> result = [];
    for (var luts in lutsByProfile.values) {
      result.addAll(luts);
    }
    return result;
  }
}

/// Information about a single LUT file
class LutInfo {
  final String assetPath;
  final String camera;
  final String profile;
  final String target;
  final String displayName;

  const LutInfo({
    required this.assetPath,
    required this.camera,
    required this.profile,
    required this.target,
    required this.displayName,
  });
}
