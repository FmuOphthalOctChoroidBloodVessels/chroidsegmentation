function imds = resizeImages(imds, imageFolder,imageSize)
% Resize images to imageSize.

if ~exist(imageFolder,'dir') ;
    mkdir(imageFolder);
else
    imds = imageDatastore(imageFolder);
    return; % Skip if images already resized
end

reset(imds);
while hasdata(imds);
    % Read an image.
    [I,info] = read(imds);     
    
    % Resize image.
    I=cat(3,I,I,I);
    I = imresize(I,imageSize);    
    
    % Write to disk.
    [~, filename, ext] = fileparts(info.Filename);
    imwrite(I,[imageFolder filename ext]);
end

imds = imageDatastore(imageFolder);
end