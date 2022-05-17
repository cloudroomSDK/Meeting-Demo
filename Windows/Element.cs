using System.Drawing;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace Meeting_WPF
{
    enum Style { // pen style
        SolidLine = 1,
        DotLine = 3
    };

    enum DrawType
    {
        //SHAPE_NULL=0,
        //INDICATE,	//指示器
        //HOTSPOT,	//热点
        //TURNPAGEPIC,//

        PENCIL = 4,		//铅笔
        //NITEPEN,	//荧光笔
        LINE = 6,		//直线
        //LINEARROW1,	//单向箭头
        //LINEARROW2,	//双向箭头
        //TEXT,		//文本
        //FILLRECT,	//直角矩形(实心)
        //HOLLRECT,	//直角矩形(空心)
        //FILLROUNDRECT,	//圆角矩形(实心)
        //HOLLROUNDRECT,	//圆角矩形(空心)
        //FILLELLIPSE,	//椭圆(实心)
        //HOLLELLIPSE,	//椭圆(空心)
        //IMAGE,		//贴图
    };

    public class Element
    {
        public string elementID;
        public int orderId;
        public short left;
        public short top;
        public int type;
        public uint color;
        public int pixel;
        public int style;
        public Element()
        {
            orderId = 10000000; //默认初始值，添加图元成功后由服务端产生新值
            color = (uint)Color.Black.ToArgb();//默认黑色;
            pixel = 2;
            style = (int)Style.SolidLine;
        }
    }
    public class Dot
    {
        public int x;
        public int y;
        
        public Dot() { }
        public Dot(int x, int y) 
        { 
            this.x = x; 
            this.y = y; 
        }
        public Dot(float x, float y) 
        { 
            this.x = (int)x; 
            this.y = (int)y; 
        }
    }
    public class ElementPen : Element
    {
        public List<Dot> dot;// = new List<Dot>();

    }
    /* 画笔数据json格式示例
    {
      "userID": "testuser",
      "elementID": 123,
      "orderId": 123,
      "left": 123,
      "top": 123,
      "type": 4, //PENCIL
      "color": [255,255,255],
      "pixel": 2,
      "style": 1, //SolidLine 
      "dot": [
        {
          "x": 1,
          "y": 1
        },
        {
          "x": 2,
          "y": 2
        },
        {
          "x": 3,
          "y": 3
        },
         ......
      ]
    }*/

    public struct Line
    {
        public short x1;
        public short y1;
        public short x2;
        public short y2;
    }

    public class ElementLine : Element
    {
        public Line line = new Line();
    }

    /*直线数据json格式示例
    {
      "userID": "testUser",
      "elementID": 12,
      "orderId": 123,
      "left": 34,
      "top": 43,
      "type": 6, //LINE
      "color": [122,122,122],
      "pixel": 2,
      "style": 1, //SolidLine  
      "line": {
          "x1": 1,
          "y1": 1,
          "x2": 100,
          "y2": 100
        }
    }
    */

    //"pageID": "111", "title": "borad1","width": 1024,"height": 768}
    public class WBoard //白板页
    {
        public string wBoardID;
        public string title;
        public int width;
        public int height;
        public int pageCount;

        public WBoard()
        {
            
        }

        public WBoard(string id, string t, int w, int h, int p)
        {
            wBoardID = id;
            title = t;
            width = w;
            height = h;
            pageCount = p;
        }
    }
}
