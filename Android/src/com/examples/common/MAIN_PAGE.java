package com.examples.common;

/**
 * 主功能页
 * 
 * @author hedonghai
 * 
 */
public enum MAIN_PAGE {
	/**
	 * 未知页
	 */
	MAINPAGE_UNKNOW(-1),
	/**
	 * 视频墙
	 */
	MAINPAGE_VIDEOWALL(0),
	/**
	 * 屏幕共享
	 */
	MAINPAGE_SCREENSHARE(1),
	/**
	 * 白板
	 */
	MAINPAGE_WHITEBOARD(2),
	/**
	 * 影音共享
	 */
	MAINPAGE_MEDIASHARE(3);

	private int value;

	private MAIN_PAGE(int value) {
		this.value = value;
	}

	public int value() {
		return this.value;
	}

	@SuppressWarnings("unused")
	private int MAIN_PAGE_value() {
		return this.value();
	}

	@SuppressWarnings("unused")
	private static MAIN_PAGE valueOf(int value) {
		MAIN_PAGE tmp = MAINPAGE_VIDEOWALL;
		MAIN_PAGE[] vals = MAIN_PAGE.values();
		for (MAIN_PAGE val : vals) {
			if (val.value() == value) {
				tmp = val;
				break;
			}
		}
		return tmp;
	}
}
