using System.Collections.Generic;

namespace SDKDemo
{
    public class CRError
    {
        private static CRError instance = null; 
        Dictionary<int, string> errorDict = new Dictionary<int, string>();

        public CRError()
        {
            initDict();
        }

        public static CRError Instance
        {
            get 
            {
                if(instance == null)
                {
                    instance = new CRError();
                }
                return instance; 
            }
        }

        public string getError(int code)
        {
            if (errorDict.ContainsKey(code))
                return "\n" + errorDict[code] + string.Format("[{0}]", code);
            else
                return "\nSDK未定义错误:" + string.Format("[{0}]", code);
        }

        private void initDict()
        {
            errorDict.Add(0, "没有错误");
            errorDict.Add(1, "未知错误");
            errorDict.Add(2, "内存不足");
            errorDict.Add(3, "sdk内部错误");
            errorDict.Add(4, "不支持的sdk版本");
            errorDict.Add(5, "参数错误");
            errorDict.Add(6, "无效数据");
            errorDict.Add(7, "AppID或AppSecret不正确");
            errorDict.Add(8, "服务异常");
            errorDict.Add(9, "登录状态错误");
            errorDict.Add(10, "帐号在别处被使用");
            errorDict.Add(11, "sdk未初始化");
            errorDict.Add(12, "还没有登录");
            errorDict.Add(13, "base64转换失败");

            errorDict.Add(18, "token已过期");
            errorDict.Add(19, "鉴权信息错误");
            errorDict.Add(20, "appid不存在");
            errorDict.Add(21, "鉴权失败");
            errorDict.Add(22, "非token鉴权方式");

            errorDict.Add(200, "网络初始化失败");
            errorDict.Add(201, "没有服务器信息");
            errorDict.Add(202, "服务器没有响应");
            errorDict.Add(203, "创建连接失败");
            errorDict.Add(204, "socket异常");
            errorDict.Add(205, "网络超时");
            errorDict.Add(206, "连接被关闭");
            errorDict.Add(207, "连接丢失");
            errorDict.Add(208, "语音引擎初始化失败");
            errorDict.Add(209, "ssl通信错误");
            errorDict.Add(210, "响应数据不正确");

            errorDict.Add(400, "队列ID错误");
            errorDict.Add(401, "没有用户在排队");
            errorDict.Add(402, "排队用户已取消");
            errorDict.Add(403, "队列服务还未开启");
            errorDict.Add(404, "已在其它队列排队(客户只能在一个队列排队)");

            errorDict.Add(600, "无效的呼叫ID");
            errorDict.Add(601, "已在呼叫中");
            errorDict.Add(602, "对方忙");
            errorDict.Add(603, "对方不在线");
            errorDict.Add(604, "对方无应答");
            errorDict.Add(605, "用户不存在");
            errorDict.Add(606, "对方拒接");

            errorDict.Add(800, "会议不存在或已结束");
            errorDict.Add(801, "会议密码不正确");
            errorDict.Add(802, "会议终端数量已满（购买的license不够)");
            errorDict.Add(803, "分配会议资源失败");
            errorDict.Add(804, "会议已加锁");
            errorDict.Add(805, "余额不足");
            errorDict.Add(806, "业务权限未开启");
            errorDict.Add(807, "不能再次登录");

            errorDict.Add(900, "抓屏失败");
            errorDict.Add(901, "单次录制达到最大时长(8h)");
            errorDict.Add(902, "磁盘空间不够");
            errorDict.Add(903, "录制尺寸超出了允许值");
            errorDict.Add(904, "录制参数超出限制");
            errorDict.Add(905, "录制文件操作出错");
            errorDict.Add(907, "录制服务器资源不足");
            errorDict.Add(908, "云端录像空间已满");

            errorDict.Add(1000, "发送失败");
            errorDict.Add(1001, "有敏感词语");

            errorDict.Add(1100, "发送信令数据过大");
            errorDict.Add(1101, "发送数据过大");
            errorDict.Add(1102, "目标用户不存在");
            errorDict.Add(1103, "文件错误");
            errorDict.Add(1104, "无效的发送id");

            errorDict.Add(1200, "状态错误不可上传/取消上传");
            errorDict.Add(1201, "录制文件不存在");
            errorDict.Add(1202, "上传失败，失败原因参考日志");
            errorDict.Add(1203, "移除本地文件失败");

            errorDict.Add(1300, "ipcam url不正确");
            errorDict.Add(1301, "ipcam已存在");
            errorDict.Add(1302, "添加太多ip cam");

            errorDict.Add(1400, "文件不存在");
            errorDict.Add(1401, "文件读失败");
            errorDict.Add(1402, "文件写失败");
        }
    };
}