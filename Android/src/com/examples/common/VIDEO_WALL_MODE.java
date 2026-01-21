package com.examples.common;

/**
 * 视频墙分屏模式
 * 
 * @author hedonghai
 * 
 */

public enum VIDEO_WALL_MODE {
	/**
	 * 1V1分屏互看模式
	 */
	VLO_1v1_M(0),
	/**
	 * 1分屏
	 */
	VLO_WALL1_M(1),
	/**
	 * 2分屏
	 */
	VLO_WALL2(2),
	/**
	 * 4分屏
	 */
	VLO_WALL4(4),
	/**
	 * 5分屏
	 */
	VLO_WALL5_M(5),
	/**
	 * 6分屏
	 */
	VLO_WALL6_M(6),
	/**
	 * 9分屏
	 */
	VLO_WALL9(9),
	/**
	 * 13分屏
	 */
	VLO_WALL13_M(13),
	/**
	 * 16分屏
	 */
	VLO_WALL16(16),
	/**
	 * 25分屏
	 */
	VLO_WALL25(25),

	VLO_WALL27_M(27),

	VLO_WALL33_M(33),

	VLO_WALL36(36);

	private int value = 0;

	private VIDEO_WALL_MODE(int value) {
		this.value = value;
	}

	private int value() {
		return value;
	}

	@SuppressWarnings("unused")
	private int VIDEO_WALL_MODE_value() {
		return this.value();
	}

	@SuppressWarnings("unused")
	private static VIDEO_WALL_MODE valueOf(int value) {
		VIDEO_WALL_MODE tmp = VLO_1v1_M;
		VIDEO_WALL_MODE[] vals = VIDEO_WALL_MODE.values();
		for (VIDEO_WALL_MODE val : vals) {
			if (val.value() == value) {
				tmp = val;
				break;
			} else if (val.value() < value) {
				tmp = val;
			}
		}
		return tmp;
	}
}
