currentFolder=cd;
cd('../result')
FolderSize=dir('*.mat');
cd(currentFolder)

for i=1:size(FolderSize,1)
    file=strcat(FolderSize(i).folder,'\',FolderSize(i).name);
    load(file)

    x = {linspace(1,size(test1,1),size(test1,2)),linspace(1,size(test1,1),size(test1,2))};
    smoother1 = csaps(x,test3,0.01,x);
    smoother2= csaps(x,test4,0.01,x);
    smoother=smoother2-smoother1;

    Max=max(max(smoother,[],1),[],2);
    Min=min(min(smoother,[],1),[],2);

    Matrix=ones(size(test1,1),size(test1,2));

    smootherRel=64.*(smoother-(Min*Matrix))./(Max*Matrix-Min*Matrix);

    figure1 = figure('Position',[1,1,1028,880],'Color',[1 1 1]);
    image(smootherRel)
    set(gca,'FontSize',40);

    c=jet(64);
    colormap(c);
    c=colorbar;
    c.Label.String = 'Thickness';
    c.Label.FontSize=48;
    c.FontSize = 30;
    xlabel('x axis (pixel)','FontSize',48);
    ylabel('y axis (pixel)','FontSize',48);
    daspect([1 1 1]);
    
    filename=strcat('../result/',erase(FolderSize(i).name,'.mat'),'_contour_relative.tif');
    saveas(gcf,filename)
    
end