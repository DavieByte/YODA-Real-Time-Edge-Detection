import cv2
import numpy as np

# Read in the image
img = cv2.imread('ctqq.jpg')

# Convert the image to grayscale
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# Apply Gaussian blur to reduce noise
blurred = cv2.GaussianBlur(gray, (3, 3), 0)

# Define the lower and upper thresholds for Canny edge detection
threshold1 = 100
threshold2 = 200

# Perform Canny edge detection
edges = cv2.Canny(blurred, threshold1, threshold2)

# Perform non-maximum suppression
for i in range(1, edges.shape[0]-1):
    for j in range(1, edges.shape[1]-1):
        if edges[i, j] != 0:
            mag = np.sqrt(edges[i, j] ** 2 + edges[i+1, j] ** 2 + edges[i-1, j] ** 2 + edges[i, j+1] ** 2 + edges[i, j-1] ** 2)
            if mag == 0:
                edges[i, j] = 0
            else:
                grad = edges[i, j] / mag
                if grad > 0.4142:  # 22.5 degrees in radians
                    if edges[i-1, j] < edges[i, j] > edges[i+1, j]:
                        edges[i, j] = edges[i, j]
                    else:
                        edges[i, j] = 0
                elif grad > -0.4142:
                    if edges[i-1, j+1] < edges[i, j] > edges[i+1, j-1]:
                        edges[i, j] = edges[i, j]
                    else:
                        edges[i, j] = 0
                elif grad > -2.4142:
                    if edges[i, j-1] < edges[i, j] > edges[i, j+1]:
                        edges[i, j] = edges[i, j]
                    else:
                        edges[i, j] = 0
                else:
                    if edges[i-1, j-1] < edges[i, j] > edges[i+1, j+1]:
                        edges[i, j] = edges[i, j]
                    else:
                        edges[i, j] = 0

# Display the resulting image
cv2.imshow('Edges', edges)
cv2.waitKey(0)
cv2.destroyAllWindows()
