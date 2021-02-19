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

    figure1 = figure('Color',[1 1 1],'Position',[1,1,1028,880]);
    image(smoother)
    set(gca,'FontSize',40);
    
	c=jet(64);
	colormap(c);
    c=colorbar;fig = gcf;
    fig.PaperPositionMode = 'auto'
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    c.TickLabels={'120','240','360','480','600','720'};
    c.Label.String = 'Thickness (um)';
    c.Label.FontSize=48;
    c.FontSize = 30;
    xlabel('x axis (pixel)','FontSize',48);
    ylabel('y axis (pixel)','FontSize',48);
    daspect([1 1 1]);
    
    filename=strcat('../result/',erase(FolderSize(i).name,'.mat'),'_contour.tif');
    saveas(gcf,filename)
    
end