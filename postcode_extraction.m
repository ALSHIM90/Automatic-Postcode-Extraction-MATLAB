img = imread('envelope1.jpg.png'); 

gray_img = rgb2gray(img); 
binary_img = ~imbinarize(gray_img); 
clean_img = bwareaopen(binary_img, 30);

se = strel('rectangle', [3, 15]); 
dilated_img = imdilate(clean_img, se);
stats = regionprops(dilated_img, 'BoundingBox', 'Area');

postcode_box = [];
[img_height, ~] = size(gray_img);

for k = 1:length(stats)
    box = stats(k).BoundingBox;
    x = box(1); y = box(2); w = box(3); h = box(4);
    aspect_ratio = w / h;

    if (aspect_ratio > 2.0 && aspect_ratio < 8.0) && (y > img_height * 0.4) && (h > 10 && h < 60)
        postcode_box = box;
    end
end

postcode_crop = imcrop(img, postcode_box);

postcode_gray = rgb2gray(postcode_crop);
postcode_bin = ~imbinarize(postcode_gray);
postcode_clean = bwareaopen(postcode_bin, 10);

digit_stats = regionprops(postcode_clean, 'BoundingBox', 'Image');

recognized_digits = '';

for i = 1:length(digit_stats)
    sub_digit = digit_stats(i).Image;
    box = digit_stats(i).BoundingBox;

    w = box(3); h = box(4);

    if box(1) > 35
        eul = eulernumber(sub_digit);
        holes = 1 - eul;

        if holes == 2
            digit = '8';
        elseif holes == 1
            digit_stats_hole = regionprops(~sub_digit, 'Centroid');
            if length(digit_stats_hole) >= 2
                cy = digit_stats_hole(2).Centroid(2);
                if cy > h/2
                    digit = '6';
                else
                    digit = '0';
                end
            else
                digit = '0';
            end
        else
            digit = '2'; 
        end

        recognized_digits = [recognized_digits, digit];
    end
end

figure;
imshow(postcode_crop);
title(['Recognized Postcode: ', recognized_digits], 'FontSize', 14, 'Color', 'b');

fprintf('\n=======================================\n');
fprintf('  RECOGNIZED POSTCODE: %s\n', recognized_digits);
fprintf('=======================================\n\n');