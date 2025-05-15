# Dockerfile may have following Arguments:
# tag - tag for the Base image, (e.g. 2.9.1 for tensorflow)
#
# To build the image:
# $ docker build -t <dockerhub_user>/<dockerhub_repo> --build-arg arg=value .
# or using default args:
# $ docker build -t <dockerhub_user>/<dockerhub_repo> .
#
# Be Aware! For the Jenkins CI/CD pipeline, 
# input args are defined inside the JenkinsConstants.groovy, not here!

ARG tag=latest

# Base image, e.g. tensorflow/tensorflow:2.9.1
FROM ai4oshub/ai4os-yolov8-torch:${tag}

LABEL maintainer='Damian Smyth'
LABEL version='0.0.1'
# AI-based Marine animal types detection and classification algorithm based on YOLOv8. The model has been tuned to detect and classify marine animal types at the Smartbay underwater observatory

# Download new model weights and remove old ones
# You can use the following as "reference" - https://github.com/ai4os-hub/ai4os-image-classification-tf/blob/master/Dockerfile
###############
### FILL ME ###
###############
ENV YOLOV8_DEFAULT_WEIGHTS="yolov8_smartbay_marine_types_small"
ENV YOLOV8_DEFAULT_TASK_TYPE="det"

# Uninstall existing module ("yolov8_api")
# Update MODEL_NAME to smartbay_marine_types_detection
# Copy updated pyproject.toml to include Smartbay authors and rename the module
# Re-install application with the updated pyproject.toml
RUN cd /srv/ai4os-yolov8-torch && \
    module=$(cat pyproject.toml |grep '\[project\]' -A1 |grep 'name' | cut -d'=' -f2 |tr -d ' ' |tr -d '"') && \
    pip uninstall -y $module
ENV MODEL_NAME="smartbay_marine_types_detection"
COPY ./pyproject-child.toml /srv/ai4os-yolov8-torch/pyproject.toml
RUN cd /srv/ai4os-yolov8-torch && pip install --no-cache -e .
RUN mkdir -p /srv/ai4os-yolov8-torch/models/yolov8_smartbay_marine_types_small/weights && \
 curl -L https://zenodo.org/records/15366751/files/smartbay-species-marine-fish-marine-types-t3-3-yolo8s_01.pt \
 --output /srv/ai4os-yolov8-torch/models/yolov8_smartbay_marine_types_small/weights/best.pt