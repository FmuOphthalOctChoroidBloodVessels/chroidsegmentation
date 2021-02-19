function [A]=read_IMG2(filename, pixeldim)
    % TODO: マルチページTiffで保存: imwirte(im, 'myMultipageImg.tiff','WriteMode',
    % 'append');
    AScRes=pixeldim(1); % Height
    BScH=pixeldim(2); % Width
    BScV=pixeldim(3); % # Images
    fid = fopen(filename,'r');
    A=fread(fid,inf,'*uint8');
    fclose(fid);
    A=reshape(A,BScH,AScRes,BScV);
    A=permute(A,[2,1,3]);
    for i=1:BScV
        A(:,:,i)=fliplr( flipud( squeeze(A(:,:,i)) ));
    end
end