using System.Collections.Generic;
using System.Drawing;
using System;
using Newtonsoft.Json;

namespace Meeting_WPF
{
    
    enum VCALLSDK_ERR_DEF //错误枚举定义
    {
        VCALLSDK_NOERR = 0,

        //基础错误
        VCALLSDK_UNKNOWERR,                 //未知错误
        VCALLSDK_OUTOF_MEM,                 //内存不足
        VCALLSDK_INNER_ERR,                 //sdk内部错误
        VCALLSDK_MISMATCHCLIENTVER,         //不支持的sdk版本
        VCALLSDK_MEETPARAM_ERR,             //参数错误
        VCALLSDK_ERR_DATA,                  //无效数据
        VCALLSDK_ANCTPSWD_ERR,              //帐号密码不正确
        VCALLSDK_SERVER_EXCEPTION,          //服务异常
        VCALLSDK_LOGINSTATE_ERROR,			//登录状态错误
        VCALLSDK_USER_BEEN_KICKOUT,			//用户被踢掉
        VCALLSDK_NOT_INIT,                  //sdk未初始化
        VCALLSDK_NOT_LOGIN,                 //还没有登录
        VCALLSDK_BASE64_COV_ERR,            //base64转换失败

        VCALLSDK_CUSTOMAUTH_NOINFO,		//启用了第三方鉴权，但没有携带鉴权信息
        VCALLSDK_CUSTOMAUTH_NOTSUPPORT,	//没有启用第三方鉴权，但携带了鉴权信息
        VCALLSDK_CUSTOMAUTH_EXCEPTION,	//访问第三方鉴权服务异常
        VCALLSDK_CUSTOMAUTH_FAILED,		//第三方鉴权不通过

        //Token鉴权失败
        VCALLSDK_KICKOUT_INVALID_TOKEN,			//令牌失效被踢

        VCALLSDK_TOKEN_AUTHINFOERR,
        VCALLSDK_TOKEN_SECRETERR,
        VCALLSDK_TOKEN_AUTHCHECKERR,
        VCALLSDK_TOKEN_AUTHERR,
        VCALLSDK_TOKEN_AUTHINFOTIMEOUT,
        VCALLSDK_TOKEN_APPIDNOTSAME,

        //网络
        VCALLSDK_NETWORK_INITFAILED = 200,        //网络初始化失败
        VCALLSDK_NO_SERVERINFO,             //没有服务器信息
        VCALLSDK_NOSERVER_RSP,              //服务器没有响应
        VCALLSDK_CREATE_CONN_FAILED,        //创建连接失败
        VCALLSDK_SOCKETEXCEPTION,           //socket异常
        VCALLSDK_SOCKETTIMEOUT,             //网络超时
        VCALLSDK_FORCEDCLOSECONNECTION,     //连接被关闭
        VCALLSDK_CONNECTIONLOST,            //连接丢失

        //队列相关错误定义
        VCALLSDK_QUE_ID_INVALID = 400,            //队列ID错误
        VCALLSDK_QUE_NOUSER,                //没有用户在排队
        VCALLSDK_QUE_USER_CANCELLED,        //排队用户已取消
        VCALLSDK_QUE_SERVICE_NOT_START,
        VCALLSDK_ALREADY_OTHERQUE,          //已在其它队列排队(客户只能在一个队列排队)

        //呼叫
        VCALLSDK_INVALID_CALLID = 600,            //无效的呼叫ID
        VCALLSDK_ERR_CALL_EXIST,            //已在呼叫中
        VCALLSDK_ERR_BUSY,                  //对方忙
        VCALLSDK_ERR_OFFLINE,               //对方不在线
        VCALLSDK_ERR_NOANSWER,              //对方无应答
        VCALLSDK_ERR_USER_NOT_FOUND,        //用户不存在
        VCALLSDK_ERR_REFUSE,                //对方拒接

        //会话业务错误
        VCALLSDK_MEETNOTEXIST = 800,              //会议不存在或已结束
        VCALLSDK_AUTHERROR,                 //会议密码不正确
        VCALLSDK_MEMBEROVERFLOWERROR,       //会议终端数量已满（购买的license不够)
        VCALLSDK_RESOURCEALLOCATEERROR,     //分配会议资源失败
    };

    enum CRVIDEOSDK_MEETING_DROPPED_REASON
    {
        CRVIDEOSDK_DROPPED_TIMEOUT = 0,	//网络通信超时
        CRVIDEOSDK_DROPPED_KICKOUT,		//被他人请出会议
        CRVIDEOSDK_DROPPED_BALANCELESS, //余额不足
        CRVIDEOSDK_DROPPED_TOKENINVALID,//Token鉴权方式下，token无效或过期
    };


    //设置视频尺寸
    enum VIDEO_SHOW_SIZE
    {
        VIDEO_SZ_80 = 1,     //144*80,   缺省：56kbps
        VSIZE_SZ_128,       //224*128,  缺省：72kbps
        VSIZE_SZ_160,       //288*160,  缺省：100kbps
        VSIZE_SZ_192,       //336*192,  缺省：150kbps
        VSIZE_SZ_256,       //448*256,  缺省：200kbps
        VSIZE_SZ_288,       //512*288,  缺省：250kbps
        VSIZE_SZ_320,       //576*320,  缺省：300kbps
        VSIZE_SZ_360,       //640*360,  缺省：350kbps
        VSIZE_SZ_400,       //720*400,  缺省：420kbps
        VSIZE_SZ_480,       //848*480,  缺省：500kbps
        VSIZE_SZ_576,       //1024*576,  缺省：650kbps
        VSIZE_SZ_720,       //1280*720,  缺省：1mbps
        VSIZE_SZ_1080,      //1920*1080, 缺省：2mbps
    };

    //音频状态
    enum ASTATUS
    {
        AUNKNOWN = 0,
        ANULL,
        ACLOSE,
        AOPEN,
        AOPENING,   //请求开麦中
    };
    //视频状态
    enum VSTATUS
    {
        VUNKNOWN = 0,
        VNULL,
        VCLOSE,
        VOPEN,
        VOPENING
    };

    enum MAIN_PAGE_TYPE { MAINPAGE_VIDEOWALL, MAINPAGE_SHARE, MAINPAGE_WHITEBOARD, MAINPAGE_MEDIASHARE,  MAINPAGE_NULL};//视频墙、共享、白板
    //视频墙分屏模式
    enum VIDEOWALL_MODE
    {
        VLO_WALL1 = 1,
        VLO_WALL2 = 2,
        VLO_WALL4 = 4,
        VLO_WALL5 = 5,
        VLO_WALL6 = 6,
        VLO_WALL9 = 9,
        VLO_WALL13 = 13,
        VLO_WALL16 = 16,
    };

    enum MIXER_STATE //录制状态
    {
        MST_NULL = 0,
        MST_STARTING,
        MST_RUNNING,
        MST_PAUSED,
        MST_STOPPING
    };

    enum MIXER_OUTPUT_TYPE
    {
        MIXOT_FILE = 0,
        MIXOT_LIVE
    };

    enum LOCMIXER_OUTPUT_STATE
    {
        LOCMOST_CREATE = 0,
        LOCMOST_INFOUPDATE,
        LOCMOST_CLOSE,
        LOCMOST_ERR
    }

    enum CLOUDMIXER_OUTPUT_STATE
    {
        CLOUDMOST_NULL = 0,    //未录制
        CLOUDMOST_RUNNING,     //录制中
        CLOUDMOST_STOPPED,     //录制结束
        CLOUDMOST_FAIL,        //录制失败
    }

    enum MIXER_VCONTENT_TYPE
    {
        MIXVTP_VIDEO = 0,
        MIXVTP_PIC,
        MIXVTP_SCREEN,
        MIXVTP_MEDIA,
        MIXVTP_SCREEN_SHARED = 5,
        MIXVTP_WBOARD,
        MIXVTP_TEXT = 10,
    };

    public class MeetInfo
    {
        public int ID;
    }
    
    public class InviteMeetInfo
    {
        public MeetInfo meeting;
    }

    public class VideoCfg
    {
        public int sizeType;
        public int fps;
        public int maxbps;
        public int qp_min;
        public int qp_max;
        public int wh_rate;
    }

    //{ "catchRect":[{"left":10,"top":10,"width":100,"height":100}], "catchWnd":1234, "maxFPS":8, "maxKbps":800 }

    public class ScreenShareCfg
    {
        public int catchWnd;
        public int maxFPS = 8;
        public int maxKbps = 800;
        public int shareSound = 1;
    }

    public class ScreenAreaShareCfg : ScreenShareCfg
    {
        public class CatchRect
        {
            public int left;
            public int top;
            public int width;
            public int height;
        }
        public CatchRect catchRect = new CatchRect();
    }

    public class UserVideo
    {
        public string userID;
        public int videoID;

        public UserVideo(string uID, int vID)
        {
            userID = uID; videoID = vID;
        }
    };

    //{"userID":"111","videoID":2,"videoName":"camera2"}
    public class VideoInfo
    {
        public string userID;
        public int videoID;
        public string videoName;
    };

    public class AudioCfg
    {
        public string micName;
        public string speakerName;
        public int agc;
        public int ans;
        public int aec;
    };
 
    class paramCam
    {
        public string camid;
    }

    public class MixerContentObj
    {
        public int type;
        public int keepAspectRatio;
        public int left;
        public int top;
        public int width;
        public int height;
        public object param;
    }

    public class LocMixerCfgObj
    {
        public int width;
        public int height;
        public int frameRate;
        public int bitRate;
        public int defaultQP;
        public int gop;
    }

    public class LocMixerOutputInfoObj
    {
        public int state;
        public int duration;
        public int filesize;
        public int errCode;
    }

    public class LocMixeroutputObjFile
    {
        public int type;
        public string filename;
        public int encryptType;
        public int isUploadOnRecording;
        public string serverPathFileName;
        public string liveUrl;
        public int errRetryTimes;
    }

 
    public class CamParams
    {
        public string camid;
    };

    public class ScreenParams
    {
        public int screenid = -1;
        public string area = "";
    };

    public class CloudMixerInfo
    {
        public string ID;
        public string owner;
        public string cfg;
        public int state;
    }

    public class CloudMixerVideoFileCfg
    {
        public int aStreamType = 1;
        public int vWidth;
        public int vHeight;
        public int vFps;
        public int vBps;
        public int vQP;
        public string svrPathName;
        public object layoutConfig;
    }

    public class CloudMixerCfgObj
    {
        public int mode = 0;
        public CloudMixerVideoFileCfg videoFileCfg;
    }

    public class CloudMixerOutputInfo
    {
        public string id;
        public int state;
        public string svrFilePathName;
        public long startTime;
        public long fileSize;
        public int duration;
        public int errCode;
        public string errDesc;
        public float progress; //0~100
    }

    public class CloudMixerErrInfo
    {
        public int err;
        public string errDesc;
    }


    public class PcmCFG
    {
        public int recordObject;		//0:mic, 1:spkeaker
        public string filePathName;	    //d:/record/test.pcm
    };

    //{"userID":"111","nickName":"aaa","audioStatus":"1","videoStatus":"1"}
    public class MemberInfo
    {
        public string userID;
        public string nickName;
        public int audioStatus;
        public int videoStatus;
    }

    //{"ID":"100","pswd":"","subject":""}
    public class MeetObj
    {
        public int ID;
        public string pswd;
        public string subject;
    }
    
    public class CRTools
    {
        /// <summary>
        /// 获取对应布局中的视频窗口大小
        /// </summary>
        /// <param name="layoutCount"></param>
        /// <param name="pw"></param>
        /// <param name="ph"></param>
        /// <param name="margin"></param>
        /// <param name="space"></param>
        /// <param name="videoRation"</param>
        /// <returns></returns>
        public static SizeF getVideoUISize(int layoutCount, float pw, float ph, float margin, float space, float ration)
        {            
            float ui_w = 0;
            float ui_h = 0;

            if (layoutCount == 2)
            {
                ui_w = (pw - margin - space) / 2;
                ui_h = ph;                
            }
            else if (layoutCount == 4)
            {
                ui_w = (pw - margin * 2 - space) / 2;
                ui_h = (ph - margin * 2 - space) / 2;                
            }
            else if (layoutCount == 6)
            {
                ui_w = (pw - margin * 2 - space * 2) / 3;
                ui_h = (ph - margin * 2 - space * 2) / 3;                
            }
            float w = Math.Min(ui_w, ui_h * ration);
            return new SizeF(w + 0.5F, w / ration + 0.5F);
        }
        /// <summary>
        /// 获取对于布局下的各个视频窗口位置信息
        /// </summary>
        /// <param name="layoutCount">布局：目前支持2、4、6分屏</param>
        /// <param name="pw">布局区域的宽度</param>
        /// <param name="ph">布局区域的高度</param>
        /// <param name="margin">视频区域距离四周的距离</param>
        /// <param name="space">各个视频区域的间距</param>
        /// <returns>各个视频区域的位置信息列表</returns>
        public static List<RectangleF> getVideoUiRect(int layoutCount, float pw, float ph, float margin, float space, float videoRation)
        {
            List<RectangleF> videoUIs = new List<RectangleF>();
            SizeF sz = getVideoUISize(layoutCount, pw, ph, margin, space, videoRation);
            if (layoutCount == 2)
            {
                float x1 = margin / 2;
                float y1 = (ph - sz.Height) / 2;
                videoUIs.Add(new RectangleF(new PointF(x1, y1), sz));

                float x2 = x1 + sz.Width + space;
                videoUIs.Add(new RectangleF(new PointF(x2, y1), sz));
            }
            else if (layoutCount == 4)
            {
                float x1 = (pw - sz.Width * 2 - space) / 2;
                float y1 = (ph - sz.Height * 2 - space) / 2;

                videoUIs.Add(new RectangleF(new PointF(x1, y1), sz));

                float x2 = x1 + sz.Width + space;
                videoUIs.Add(new RectangleF(new PointF(x2, y1), sz));

                float y3 = y1 + sz.Height + space;
                videoUIs.Add(new RectangleF(new PointF(x1, y3), sz));

                videoUIs.Add(new RectangleF(new PointF(x2, y3), sz));
            }
            else if (layoutCount == 6)
            {
                float x1 = (pw - sz.Width * 3 - 2 * space) / 2;
                float y1 = (ph - sz.Height * 3 - 2 * space) / 2;

                float w1 = sz.Width * 2/* + space*/;
                float h1 = sz.Height * 2/* + space*/;
                videoUIs.Add(new RectangleF(new PointF(x1, y1), new SizeF(w1, h1)));//第一个是大视频

                float x2 = x1 + sz.Width * 2 + space * 2;
                videoUIs.Add(new RectangleF(new PointF(x2, y1), sz));

                float y3 = y1 + sz.Height + space;
                videoUIs.Add(new RectangleF(new PointF(x2, y3), sz));

                float y4 = y1 + sz.Height * 2 + space * 2;
                videoUIs.Add(new RectangleF(new PointF(x1, y4), sz));

                float x5 = x1 + sz.Width + space;
                videoUIs.Add(new RectangleF(new PointF(x5, y4), sz));

                float x6 = x5 + sz.Width + space;
                videoUIs.Add(new RectangleF(new PointF(x6, y4), sz));
            }
            return videoUIs;
        }
    };
}
