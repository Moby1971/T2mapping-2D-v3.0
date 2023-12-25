function [images, complexImages] = fftReco(app)

% -----------------------------------------------------------------------
%
% Performs a FFT reconstruction of the raw k-space data
%
% Gustav Strijkers
% Amsterdam UMC
% g.j.strijkers@amsterdamumc.nl
% Dec 2023
%
%------------------------------------------------------------


if app.data3dFlag

    % 3D FFT
    kspacesum = zeros(app.dimx,app.dimy,app.ns);
    for coil = 1:app.nrCoils
        kspacesum = kspacesum + squeeze(sum(app.data{coil},[1 5]));
    end
    [~,idx] = max(kspacesum(:));
    [lev, row, col] = ind2sub(size(kspacesum),idx);
    tukeyfilter = circtukey3D(app.dimx,app.dimy,app.ns,lev,row,col,0.1);

    complexImages = zeros(app.ne,app.dimx,app.dimy,app.ns,app.nd,app.nrCoils);
    for dynamic = 1:app.nd
        for echo = 1:app.ne
            for coil = 1:app.nrCoils
                complexImages(echo,:,:,:,dynamic,coil) = fft3reco(squeeze(app.data{coil}(echo,:,:,:,dynamic)).*tukeyfilter);
            end
        end
    end
    images = rssq(complexImages,6);

else

    % 2D FFT
    kspacesum = zeros(app.dimx,app.dimy);
    for coil = 1:app.nrCoils
        kspacesum = kspacesum + squeeze(sum(app.data{coil},[1 4 5]));
    end
    [row, col] = find(ismember(kspacesum, max(kspacesum(:))));
    tukeyfilter = circtukey2D(app.dimx,app.dimy,row,col,0.1);

    complexImages = zeros(app.ne,app.dimx,app.dimy,app.nd,app.nrCoils);
    for dynamic = 1:app.nd
        for echo = 1:app.ne
            for slice = 1:app.ns
                for coil = 1:app.nrCoils
                    complexImages(echo,:,:,slice,dynamic,coil) = fft2reco(squeeze(app.data{coil}(echo,:,:,slice,dynamic)).*tukeyfilter);
                end
            end
        end
    end
    images = rssq(complexImages,6);

end

end
