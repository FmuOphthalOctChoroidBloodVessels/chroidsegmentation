function step2_smoothing_spline(folder,net,OrgvolSize)

p = gcp('nocreate');
if isempty(p)
    %parpool('local',6);
end

currentFolder=cd;
cd(folder)
%FolderSize=dir('*.tif'); % List mTIFs in a foder
octImgList = dir('*.img'); % list oct-images in a folder
cd(currentFolder)


ImgName=string(zeros(size(octImgList,1),1));
for n=1:size(octImgList,1)
    ImgName(n)=string(octImgList(n).name);  
end

ImgName=string(zeros(size(octImgList,1),1));
for n=1:size(octImgList,1)
    ImgName(n)=string(octImgList(n).name);
end
Num=find(contains(ImgName,'_cube'));
ImgName=ImgName(Num);

for iOCT=1:size(ImgName,1) % process every OCT-Image
    
    FileName=strcat('../result/',erase(ImgName(iOCT),'.img'),'.mat');
    file=strcat(octImgList(Num(iOCT)).folder,'\', octImgList(Num(iOCT)).name); % path and name of an OCT-image

%% segment the area of choroid using SegNet and Detecting it's edge in the image of No.1

    cmap=[0.7529,0,0;0,0,0.7529];
    
    volSize=[256 500 500];
    vol=zeros([volSize(1)-1,volSize(2),volSize(3)]);
    V = read_IMG2(file, OrgvolSize);
    V=imresize3(V,volSize);
    
    parfor n=1:volSize(3) % process every Slice in an mTIF
        %I=imread(file,n); % read a slice in an mTIF % TODO: .imgファイルを読み込むようにする
        I = V(:, :, n);
        C=semanticseg(I,net);

        B = labeloverlay(I, C, 'Colormap', cmap, 'Transparency',0);

        J = rgb2hsv(B);
        channel1Min = 0.601;
        channel1Max = 0.694;
        channel2Min = 0.000;
        channel2Max = 1.000;
        channel3Min = 0.000;
        channel3Max = 1.000;
        sliderBW = (J(:,:,1) >= channel1Min ) & (J(:,:,1) <= channel1Max) & ...
            (J(:,:,2) >= channel2Min ) & (J(:,:,2) <= channel2Max) & ...
            (J(:,:,3) >= channel3Min ) & (J(:,:,3) <= channel3Max);
        J = sliderBW;

        J=bwareafilt(J,1);
        se90 = strel('line', 3, 90);
        se0 = strel('line', 3, 0);
        J = imdilate(J, [se90 se0]);
        J=imfill(J,'holes');
        seD = strel('diamond',1);
        J = imerode(J,seD);
        J = imerode(J,seD);
                
        B=diff(J);
        B(B<0) = 0;

        vol(:,:,n)=B;
    end

%% Locate the coordinates of the edges of the choroid
    K=permute(vol,[2,3,1]);
	L=find(K);
	[C,~]=size(L);
	A=([volSize(2),volSize(3),volSize(1)-1]);

	x1=zeros(C,1);
	y1=zeros(C,1);
	z1=zeros(C,1);
	parfor n=1:C
        m=L(n);
        [x,y,z] = ind2sub(A,m);
        x1(n)=x;
        y1(n)=y;
        z1(n)=z;
    end

	T=table(x1,y1,z1);

%% Convert the table to the gridded data set

	x = {linspace(1,volSize(2),volSize(3)),linspace(1,volSize(2),volSize(3))};
	[xx,yy] = ndgrid(x{1},x{2});

	z2=zeros(volSize(2)*volSize(3),1);

	parfor n=1:volSize(2)*volSize(3)
        rows=T.x1 == xx(n) & T.y1 == yy(n);
        z3=T.z1(rows);
        z3=mean2(z3);
        z2(n)=z3;
    end

	test1=reshape(z2,volSize(2),volSize(3));

%% fill missing values

    FillMethod='nearest';

	test3=fillmissing(test1,FillMethod);
	test3=test3';
            
	test3=fillmissing(test3,FillMethod);
	test3=test3';

%% Spline function approximation

	x = {linspace(1,volSize(2),volSize(3)),linspace(1,volSize(2),volSize(3))};
	smoother1 = csaps(x,test3,0.01,x);

% calculating another edge
%% segment the area of choroid using SegNet and Detecting it's edge in the image of No.1

	vol=zeros([volSize(1)-1,volSize(2),volSize(3)]);        
    parfor n=1:volSize(2)
        %I=imread(file,n); % TODO: *.imgファイルを読み込むようにする
        I = V(:, :, n); 
        C=semanticseg(I,net);
        B = labeloverlay(I, C, 'Colormap', cmap, 'Transparency',0);

        J = rgb2hsv(B);
        channel1Min = 0.601;
        channel1Max = 0.694;
        channel2Min = 0.000;
        channel2Max = 1.000;
        channel3Min = 0.000;
        channel3Max = 1.000;
        sliderBW = (J(:,:,1) >= channel1Min ) & (J(:,:,1) <= channel1Max) & ...
            (J(:,:,2) >= channel2Min ) & (J(:,:,2) <= channel2Max) & ...
            (J(:,:,3) >= channel3Min ) & (J(:,:,3) <= channel3Max);
        J = sliderBW;

        J=bwareafilt(J,1);
        se90 = strel('line', 3, 90);
        se0 = strel('line', 3, 0);
        J = imdilate(J, [se90 se0]);
        J=imfill(J,'holes');
        seD = strel('diamond',1);
        J = imerode(J,seD);
        J = imerode(J,seD);

        B=diff(J);
        B(B>0) = 0;

        vol(:,:,n)=B;
	end
%% Locate the coordinates of the edges of the choroid

	K=permute(vol,[2,3,1]);
	L=find(K);
	[C,~]=size(L);
	A=([volSize(2),volSize(3),volSize(1)-1]);

	x1=zeros(C,1);
	y1=zeros(C,1);
	z1=zeros(C,1);
	parfor n=1:C
        m=L(n);
        [x,y,z] = ind2sub(A,m);
        x1(n)=x;
        y1(n)=y;
        z1(n)=z;
    end

	T=table(x1,y1,z1);

%% Convert the table to the gridded data set

	x = {linspace(1,volSize(2),volSize(3)),linspace(1,volSize(2),volSize(3))};
	[xx,yy] = ndgrid(x{1},x{2});

	z2=zeros(volSize(2)*volSize(3),1);

	parfor n=1:volSize(2)*volSize(3)
        rows=T.x1 == xx(n) & T.y1 == yy(n);
        z3=T.z1(rows);
        z3=mean2(z3);
        z2(n)=z3;
    end

	test2=reshape(z2,volSize(2),volSize(3));

%% fill missing values

	test4=fillmissing(test2,FillMethod);
	test4=test4';
            
	test4=fillmissing(test4,FillMethod);
	test4=test4';

%% Spline function approximation

	x = {linspace(1,volSize(2),volSize(3)),linspace(1,volSize(2),volSize(3))};
	smoother2 = csaps(x,test4,0.01,x);

%% Convert the grid into 3D image

	smoother1=round(smoother1);
	smoother2=round(smoother2);

	B=zeros(volSize(1),volSize(2)*volSize(3));

	for n=1:volSize(2)*volSize(3)

        B(smoother1(n):smoother2(n),n)=ones(smoother2(n)-smoother1(n)+1,1);

    end
    
    Mask = reshape(B,volSize);

%% Concatenate the images

    %V=zeros(volSize);
    
    %parfor n=1:volSize(3)
        
        %I=imread(file,n); % TODO: .imgファイルを読み込むようにする
        %V(:,:,n)=I;
        
    %end

%% Extract 3D choroid image


    Choroid=V.*uint8(Mask);
	save(FileName,'Mask','Choroid','test1','test2','test3','test4')
            
end

end