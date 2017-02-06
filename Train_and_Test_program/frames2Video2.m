%movie maker
%make movie from images in a file

pth=uigetdir;
videoName='/home/liushuang/Desktop/test.avi';
quality=100;
fps=20;
Compressed='none';

forefiles=[dir([pth '/*.jpg'])];
forefilesn=numel(forefiles);
forefileList=cell(forefilesn,1);

%生成视频的参数设定
aviobj=VideoWriter(videoName);  %创建一个avi视频文件对象，开始时其为空
aviobj.Quality=quality;
aviobj.FrameRate=fps;
%aviobj.compression=Compressed;
imgw=502;
imgh=401;

open(aviobj);
for i=1:forefilesn
    forefileList{i}=forefiles(i).name;
end

for testi=1:forefilesn
%for testi=33:39
    %for testi=220:230
    % Load a test image and candidate bounding boxes.
    %im = single(imread('VTS_01_1_1.mp420161026T14564041932.jpg')) ;
    %testfilename=imdb.images.name{testidx(testi)};
    %im = single(imread([imdb.imageDir '/' testfilename])) ;
    %strtmp=forefiles(i).name ;
    filename=forefileList{testi};
    frames=imread([pth '/' filename]);
    frames=imresize(frames,[imgh,imgw]);
    %frames=imread([framesPath,fileName,'.jpg']);
    writeVideo(aviobj,frames);
end

close(aviobj); % 关闭创建视频