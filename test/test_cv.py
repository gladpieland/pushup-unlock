import cv2


image = cv2.imread('lena.jpg')
print(type(image))

cv2.flip(image)