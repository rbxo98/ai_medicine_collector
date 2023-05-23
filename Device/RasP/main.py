from PyQt5.QtCore import *
from PyQt5.QtWidgets import *
from PyQt5.QtWebEngineWidgets import QWebEngineView
from PyQt5.QtGui import *
from PyQt5.QtMultimedia import QMediaContent, QMediaPlayer
import time
import prtc
import cam
import cv2
from threading import Thread
from ultralytics import YOLO
import firebase_admin
from firebase_admin import credentials,firestore

# Load the YOLOv8 model

cred=credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
firebase_db=firestore.client()
class WindowClass(QMainWindow,QThread):
    global firebase_db
    def __init__(self):
        super( ).__init__( )
        
        self.model = YOLO('./Model/best.pt')
        self.res=[]
        self.setGeometry(500, 500, 600, 400)
        self._webview1 = WebView()
        self._webview2 = WebView()
        self.stack = QStackedWidget(self)                   # QStackedWidget 생성
        self.stack.setGeometry(0,0,600,400)                 # 위치 및 크기 지정
        self.stack.setFrameShape(QFrame.Box) 
               # 테두리 설정(보기 쉽게)
        # 입력할 page를 QWidget으로 생성
        self.page_1 = QWidget(self)                         # page_1 생성
        self.page_2 = QWidget(self)
        self.page_3 = QWidget(self)
        self.page_4 = QWidget(self)
        self.page_5 = QWidget(self)
        
        self.vbox_1 = QVBoxLayout(self.page_1)
        self.vbox_1.setContentsMargins(0, 4, 0, 0)
        self.vbox_1.setSpacing(4)
        self.subwgt_1 = QWidget(self.page_1)
        self.subwgt_1.setSizePolicy(QSizePolicy.MinimumExpanding, QSizePolicy.Fixed)
        self.hbox_1 = QHBoxLayout(self.subwgt_1)
        self.hbox_1.setContentsMargins(4, 0, 4, 0)
        self.vbox_1.addWidget(self.subwgt_1)
        self.vbox_1.addWidget(self._webview1)
        self._webview1.load(QUrl('file:///home/user/medi/ASSETS/HTML/home.html'))
        self.media_player1 = QMediaPlayer(self.page_1)
        self.media_player1.setMedia(QMediaContent(QUrl.fromLocalFile("first.mp3")))
        self.media_player1.play()
        self.btn_1 = QPushButton(self.page_1)
        self.btn_1.setText('시작하기')
        self.btn_1.setGeometry(200, 300, 200, 40)   
        self.btn_1.setStyleSheet("border : 3px solid black; border-radius : 20px; background-color: white; ")                  # page_2 생성
        
        self.vbox_2 = QVBoxLayout(self.page_2)
        self.vbox_2.setContentsMargins(0, 4, 0, 0)
        self.vbox_2.setSpacing(4)
        self.subwgt_2 = QWidget(self.page_2)
        self.subwgt_2.setSizePolicy(QSizePolicy.MinimumExpanding, QSizePolicy.Fixed)
        self.hbox_2 = QHBoxLayout(self.subwgt_1)
        self.hbox_2.setContentsMargins(4, 0, 4, 0)
        self.vbox_2.addWidget(self.subwgt_2)
        self.vbox_2.addWidget(self._webview2)
        self._webview2.load(QUrl('file:///home/user/medi/ASSETS/HTML/second.html'))              # 위치 및 크기 지정

        self.btn_2 = QPushButton(self.page_2)               # pager_2를 부모로 btn_2 생성
        self.btn_2.setText('닫기')                         # 내용은 'btn_2'로
        self.btn_2.setGeometry(200,300,200,40) 
        self.btn_2.setStyleSheet("border : 3px solid black; border-radius : 20px; background-color: white; ")                # 위치 및 크기 지정


        self.vbox_3 = QVBoxLayout(self.page_3)
        self.label_3 = QLabel("분리중입니다. 잠시만 기다려주세요.", self.page_3)
        self.label_3.setAlignment(Qt.AlignCenter)
        self.vbox_3.addWidget(self.label_3)
        
        self.vbox_4 = QVBoxLayout(self.page_4)
        self.label_4 = QLabel("분리수거가 잘못되었습니다. 다시 배출해주세요.", self.page_4)
        self.label_4.setAlignment(Qt.AlignCenter)
        self.vbox_4.addWidget(self.label_4)

        self.btn_rethrow = QPushButton("다시 배출하기", self.page_4)
        self.btn_rethrow.clicked.connect(self.show_page_2)
        self.vbox_4.addWidget(self.btn_rethrow)

        self.btn_exit = QPushButton("종료", self.page_4)
        self.btn_exit.clicked.connect(self.show_page_1)
        self.vbox_4.addWidget(self.btn_exit)
        
        self.vbox_5 = QVBoxLayout(self.page_5)
        self.label_5 = QLabel("분리수거 done", self.page_5)
        self.label_5.setAlignment(Qt.AlignCenter)

        self.stack.addWidget(self.page_1)                   # stack에 page_1 추가
        self.stack.addWidget(self.page_2)      
        self.stack.addWidget(self.page_3)
        self.stack.addWidget(self.page_4)
        self.stack.addWidget(self.page_5)             # stack에 page_2 추가

        self.btn_1.clicked.connect(self.fnc_btn_1)          # btn_1 누르면 fnc_btn_1 호출
        self.btn_2.clicked.connect(self.fnc_btn_2)          # btn_2 누르면 fnc_btn_2 호출
    def fnc_btn_1(self):
        self.stack.setCurrentIndex(1)
        self.media_player2 = QMediaPlayer(self.page_2)
        self.media_player2.setMedia(QMediaContent(QUrl.fromLocalFile("./ASSETS/SOUNDS/second.mp3")))
        self.media_player2.play()                       # 현재 Index(페이지)를 1로
        prtc.send('door2_open')
        time.sleep(0.5)
        prtc.send('led_on')

    def fnc_btn_2(self):
        self.stack.setCurrentWidget(self.page_3)
        self.media_player3 = QMediaPlayer(self.page_2)
        self.media_player3.setMedia(QMediaContent(QUrl.fromLocalFile("./ASSETS/SOUNDS/search.mp3")))
        self.media_player3.play()
        prtc.send('door2_close')
        print("captured")
        Thread(target=self.pred,daemon=True).start()
        while not len(self.res) > 0:
            QApplication.processEvents()
        if -1 in self.res or 1 in self.res or 5 in self.res or 7 in self.res or 9 in self.res:
            self.res=[]
            prtc.send('door2_open')
            self.show_page_4()
        else :
            self.res=[]
            self.show_page_5()
          
    
    def pred(self):
        self.video = cv2.VideoCapture(0)
        _, frame = self.video.read()
        results = self.model(frame)
        clslist=list(map(int,results[0].boxes.cls.tolist()))
        self.video.release()
        if len(clslist)>0:
            self.res=clslist
        else:
            self.res=[-1]
    def show_page_4(self):
        self.stack.setCurrentWidget(self.page_4)
        self.media_player4 = QMediaPlayer(self.page_4)
        self.media_player4.setMedia(QMediaContent(QUrl.fromLocalFile("./ASSETS/SOUNDS/re.mp3")))
        self.media_player4.play()
    
    def show_page_5(self):
        self.stack.setCurrentWidget(self.page_5)
        time.sleep(1)
        prtc.send('door1_open')
        print("open")
        time.sleep(2)
        prtc.send('door1_close')
        print("close")
        time.sleep(1)
        prtc.send('led_off')
        print("off")
        time.sleep(1)
        a=prtc.rcv()
        firebase_db.collection('MachineData').document(str(100000)).update({'volume':0.78})
        QTimer.singleShot(3000, self.show_page_1)
        print("tqkf")
        
        # Call show_page_2 after 5 seconds
    def show_page_2(self):
        self.stack.setCurrentWidget(self.page_2)
        self.media_player2.play()  
    
    def show_page_1(self):
        self.stack.setCurrentWidget(self.page_1)
        self.media_player1.play()
    def fnc_changed(self):
        print("changed")
    def fnc_removed(self):
        print("removed")

    def play_sound(self):
        self.media_player.setMedia(QMediaContent(QUrl.fromLocalFile("./ASSETS/SOUNDS/sound.mp3")))
        self.media_player.play()
class WebView(QWebEngineView):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def release(self):
        self.deleteLater()
        self.close()

        
if __name__ == '__main__':
    import sys
    from PyQt5.QtCore import QCoreApplication
    from PyQt5.QtWidgets import QApplication

    QApplication.setStyle('fusion')
    app = QCoreApplication.instance()
    if app is None:
        app = QApplication(sys.argv)
    wgt_ = WindowClass()
    wgt_.show()

    app.exec_()
    wgt_.release()
    

