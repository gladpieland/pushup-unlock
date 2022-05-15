import cv2
import mediapipe as mp
import os
from concurrent.futures import ThreadPoolExecutor
import time
from datetime import datetime


current_dir = os.path.dirname(os.path.realpath(__file__))

working_dir = os.path.dirname(current_dir)
unlock_sh_path = working_dir + "/rspi/remote_unlock_mac.sh"
pid_path = working_dir + "/rspi/dest/pid"

pid = os.getpid()
pid_file = open(pid_path, "w")
pid_file.write("{}".format(pid))
pid_file.close()

mp_drawing = mp.solutions.drawing_utils
mp_pose = mp.solutions.pose

voice_speaker_enabled=True
nice_voice_enabled=True
max_count = 3
counter = 0
stage = None
video_writer = None
result_avi_file = "output.avi"

def findPosition(image, draw=True):
  lmList = []
  if results.pose_landmarks:
      mp_drawing.draw_landmarks(image, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)
      idx = 0
      msg = ''
      for id, lm in enumerate(results.pose_landmarks.landmark):
          h, w, c = image.shape
          cx, cy = int(lm.x * w), int(lm.y * h)
          lmList.append([id, cx, cy])
          if (id >= 11 and id <= 14) :
            msg += '{}:{}-{}-{};'.format(idx, id, cx, cy)
          idx += 1
          #cv2.circle(image, (cx, cy), 5, (255, 0, 0), cv2.FILLED)
      if idx > 0:
        info("{}#{}: {}".format(stage, counter, msg))
  return lmList

def info(msg):
  dt_string = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")
  print("{} - {}".format(dt_string, msg))

def writeImage(image):
  video_writer.write(image)

def speakSpeech(speechText):
  if not voice_speaker_enabled:
    info('speech speak not enable.')
    return
  os.system("espeak-ng '" + speechText + "'")

def playVoice(voiceFilePath):
  if not voice_speaker_enabled:
    info('voice play not enable.')
    return
  os.system("aplay '" + voiceFilePath + "'")

def playVoiceOrSpeech(text):
  if not voice_speaker_enabled:
    info('voice or speech not enable.')
    return
  may_path = working_dir + "/sound/" + text + ".wav"
  if nice_voice_enabled:
    if not os.path.exists(may_path):
      info("voice file#{} not exist".format(may_path))
      speakSpeech(text)
    else:
      playVoice(may_path)
  else:
    speakSpeech(text)

cap = cv2.VideoCapture(0)
counter = 0
stage = "-"
flagRadius = 10
end = False
voice_pool = ThreadPoolExecutor(max_workers=1)
output_pool = ThreadPoolExecutor(max_workers=1)

voice_pool.submit(playVoiceOrSpeech, "ready-go" )


with mp_pose.Pose(min_detection_confidence=0.7, min_tracking_confidence=0.7) as pose:
  while cap.isOpened():
    success, image = cap.read()
    image = cv2.resize(image, (640,480))
    if not success:
      info("Ignoring empty camera frame.")
      # If loading a video, use 'break' instead of 'continue'.
      continue

    # Flip the image horizontally ( 1 ) for a later selfie-view display, and convert
    # the BGR image to RGB.
    # change to Flip vertically -1
    image = cv2.cvtColor(cv2.flip(image, -1), cv2.COLOR_BGR2RGB)

    # To improve performance, optionally mark the image as not writeable to
    # pass by reference.
    results = pose.process(image)

    # Draw the pose annotation on the image.
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    lmList = findPosition(image, draw=True)
    if len(lmList) != 0:
      ## shoulder red
      cv2.circle(image, (lmList[12][1], lmList[12][2]), flagRadius, (0, 0, 255), cv2.FILLED)
      cv2.circle(image, (lmList[11][1], lmList[11][2]), flagRadius, (0, 0, 255), cv2.FILLED)

      ## elbow blue 
      cv2.circle(image, (lmList[14][1], lmList[14][2]), flagRadius, (255, 0, 0), cv2.FILLED)
      cv2.circle(image, (lmList[13][1], lmList[13][2]), flagRadius, (255, 0, 0), cv2.FILLED)

      info("check delta - {}#{}: d1#{}, d2#{}".format(stage, counter, (lmList[11][2] - lmList[13][2]), (lmList[12][2] - lmList[14][2])))

      # 11 left shoulder, 12 right shoulder
      # 13 left elbow, 14 right elbow
      # use vertically, so 
      # it's to hard do precisely down, plus delta (20)
      # if (lmList[12][2] and lmList[11][2] >= lmList[14][2] and lmList[13][2]):
      if (lmList[11][2] + 20 >= lmList[13][2] and lmList[12][2] + 20 >= lmList[14][2]):
        # sholder turn to green
        cv2.circle(image, (lmList[12][1], lmList[12][2]), flagRadius, (0, 255, 0), cv2.FILLED)
        cv2.circle(image, (lmList[11][1], lmList[11][2]), flagRadius, (0, 255, 0), cv2.FILLED)
        stage = "down"
        dt_string = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        info("down action at {}".format(dt_string))
      
      # up action must come to some distance, 
      # if (lmList[12][2] and lmList[11][2] <= lmList[14][2] and lmList[13][2]) and stage == "down":
      if ((lmList[11][2] + 0) < lmList[13][2] and (lmList[12][2] + 0) < lmList[14][2]) and stage == "down":
        stage = "up"
        info('up action')

        # elbow turn to  pink (153 51 255)
        cv2.circle(image, (lmList[14][1], lmList[14][2]), flagRadius, (153, 51, 255), cv2.FILLED)
        cv2.circle(image, (lmList[13][1], lmList[13][2]), flagRadius, (153, 51, 255), cv2.FILLED)

        counter += 1
        counter2 = str(int(counter))
        dt_string = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        info('reach count#{}\n'.format(counter))

        if counter < max_count:
          voice_pool.submit(playVoiceOrSpeech, counter2)
        elif counter == max_count:
          voice_pool.submit(playVoiceOrSpeech, "ok" )
          os.system("bash " + unlock_sh_path)
          end = True
        else:
          voice_pool.submit(playVoiceOrSpeech, counter2)

    text = "{}:{}".format("Push Ups", counter)
    cv2.putText(image, text, (10, 40), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)
    cv2.imshow('Pushup Counter', image)

    if video_writer is None:
      fourcc = cv2.VideoWriter_fourcc(*'XVID')
      video_writer = cv2.VideoWriter(result_avi_file, fourcc, 30, (image.shape[1], image.shape[0]), True)
    # video_writer.write(image)
    output_pool.submit(writeImage, image)

    key = cv2.waitKey(1) & 0xFF
    # if the `q` key was pressed, break from the loop
    if end or key == ord("q"):
      break

# do a bit of cleanup
cv2.destroyAllWindows()
voice_pool.shutdown()
output_pool.shutdown()

pid_file = open(pid_path, "w")
pid_file.write("")
pid_file.close()
