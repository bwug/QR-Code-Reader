% Very simple and primitive code
% Used only to demonstrate an understanding of MATLAB


function [code]=decode(I)
    code = []; % Keeping empty for now but might use instead of characters, depending on how matlab works

    original_size = size(I,1); % Original size of the code, 280x280 in the test case    

    positions = [];
    
    % Travels diagonally from (1,1) until it arrives at a 0
    % Position is the value of the x and y coordinates of the first character code
    for y = 1:4
        for x = 1:original_size
            if I(x,x) == 0
                positions(end+1) = x-1;
                break
            end
        end
        I = rot90(I, 1);
    end

    position = min(positions); % Because the loop will always overshoot by 1
    pixel_size = (original_size - position * 2) / 10; % Gets the size of the QR code, 20 in the test case
    normalised_matrix = [];
    for x = 1:pixel_size:original_size
        for y = 1:pixel_size:original_size
            if I(x,y) == 1
                normalised_matrix(end+1) = 1;
            else
                normalised_matrix(end+1) = 0;
            end
        end
    end
    normalised_size = original_size / pixel_size; % Gets the size of the normalised matrix, 14 in the test case
    normalised_position = normalised_size - 10;
    normalised_matrix = reshape(normalised_matrix, [], normalised_size)';

    qr_start = ((normalised_size - 10) / 2);
    
    rotated = false;
    while rotated == false
        normalised_matrix = rot90(normalised_matrix, 1);
        if normalised_matrix(qr_start+1,qr_start) == 0
            rotated = true;
        end
    end

    qr_start = qr_start + 1;
    normalised_matrix = normalised_matrix(qr_start:qr_start+9, qr_start:qr_start+9);
    code = simple_decode(normalised_matrix);
end

function [code] = simple_decode(Matrix)
    code = ""; % The output, empty at the moment

    % Following function is copied from stackoverflow
    % Calls the entire matrix in a single go, turning it into a row vector
    % Then removes all spaces from the row vector by converting to a string using substring concatenation,
    % which much easier to manage using less loops
    % Scales better for time consumption I hope
    row_vector_format = reshape(Matrix'.',1,[]);
    raw_data = strrep(num2str(row_vector_format), ' ', '');
    
    char_count = bin2dec(raw_data(1:8));
    % Gets the amount of data needed from the input stream
    % Rest of the data is unneeded

    for x = 1:char_count
        % Gets all characters from the QR code that are needed
        LB = 1 + (x * 8); % Lower Bound
        UB = 8 + (x * 8); % Upper Bound
        code = append(code, char(bin2dec((raw_data(LB:UB))))); % Yummy brackets
        % Appends the new character to the end of the characters array
    end
    code = convertStringsToChars(code); % Because they want a certain data type :(
end
