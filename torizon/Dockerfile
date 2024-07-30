FROM --platform=linux/arm/v8 torizon/wayland-base-vivante:2
 
RUN apt-get -y update && apt-get install -y --no-install-recommends \
	git build-essential	cmake net-tools v4l-utils vim \
	&& apt-get clean \
	&& apt-get autoremove \
	&& rm -rf /var/lib/apt/lists/* \
	&& git clone --branch develop https://github.com/pmliquify/v4l2-test.git \
	&& (cd v4l2-test; mkdir build; cd build; cmake ..; cmake --build .; cmake --install .) \
	&& echo "v4l2-ctl --set-fmt-video=width=5440,height=3648,pixelformat=RG10" > test.sh \
	&& echo "v4l2-test stream -p 1" >> test.sh \
	&& echo "# v4l2-test stream client --ip <your-host> -p 1" >> test.sh \
	&& chmod +x test.sh