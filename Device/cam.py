
# Open the video file


# Loop through the video frames

def pred(frame,model,res):
    # Run YOLOv8 inference on the frame
    results = model(frame)
    # Visualize the results on the frame
    res=list(map(int,results[0].boxes.cls.tolist()))
