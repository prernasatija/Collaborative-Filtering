U = load('u.data');
UniqUsers =  unique(U(:,1));
UniqItems = unique(U(:,2));
UniqRatings = unique(U(:,3));
%noOfUsers = size(UniqUsers);
%noOfItems = size(UniqItems,1);

% count of users and items
Users = histc(U(:,1),UniqUsers);
Items = histc(U(:,2),UniqItems);
Ratings = histc(U(:,3),UniqRatings);

sortedUsers = sortrows(U,1);
sortedItems = sortrows(U,2);
temp = 0;
n = 1;
count = 1;
%numrows = size(sorted,1);
while n <= 100000;
    i = 0;
    sumOfRating = 0;
    sumOfRatingSqr = 0;
    temp = sortedUsers(n + i,1);
    while (n + i) <=100000 && temp == sortedUsers(n + i,1)
        sumOfRating = sumOfRating + sortedUsers(n+i,3);
        sumOfRatingSqr = sumOfRatingSqr + (sortedUsers(n+i,3)*sortedUsers(n+i,3));
        i = i + 1;
    end
    % 3d matrix: userId , avgRating, sum of squares of ratings
    userRating(count,1) = temp;
    userRating(count,2) = sumOfRating/i;
    userRating(count,3) = sumOfRatingSqr;
    n = n + i;
    count = count + 1;
end

A = zeros(1682*943, 3);

p = 1;
r = 1;
while p <= 943
    q = 1;
    while q <= 1682
        A(r,1) = p;
        A(r,2) = q;
        q = q+1;
        r = r + 1;
    end
    p = p+1;
end

i =1;
while i <= 100000
    user = sortedUsers(i, 1)
    item = sortedUsers(i, 2)
    %rating = sortedUsers(i, 3)
    if user == 1
        j = 1;
        while j <= 1682
            if A(j,1) == user && A(j,2) == sortedUsers(i, 2)
                A(j,3) = sortedUsers(i, 3);
            else
                A(j,3) = A(j,3);
            end
            j = j + 1;
        end
    else
        j = (user - 1)*1682 + 1;
        while j <= user*1682
            if A(j,1) == user && A(j,2) == sortedUsers(i, 2)
                A(j,3) = sortedUsers(i, 3);
            else
                A(j,3) = A(j,3);
            end
            j = j + 1;
        end
    end
    i = i+1;
end

%Finding similarity between 10th user and all other users 
user = 10;
item = 10;
Neighborhood = 5;
j=1;
sum = 0;
r = 1;
    while j<=943
        % if rating of item for j != 0 
        if A((1682*(j-1)) + item,3)~= 0
            for k = 1:1682
                X = (1682*(user-1)) + k;
                Y = (1682*(j-1)) + k;
                sum = sum + (A(X,3)*A(Y,3));
            end
            similarityValue = sum/((userRating(user,3)^(0.5))*(userRating(j,3)^(0.5)));
            similarity1(r,1) = user;
            similarity1(r,2) = j;
            similarity1(r,3) = similarityValue;
            similarity1(r,4) = A((1682*(j-1)) + item,3);
            r = r+1;
            sum = 0;
            k=1;
        end
        j=j+1;
    end
    sortedSimilarUsers = sortrows(similarity1,3);
    simNumer = 0;
    simDenom = 0;
    for i=1:Neighborhood
        if r-i > 0
            neigh1(i,1) = sortedSimilarUsers(r-i,2);
            neigh1(i,2) = sortedSimilarUsers(r-i,3);
            simNumer = simNumer + (neigh1(i,2)*(sortedSimilarUsers(r-i,4)- userRating(neigh1(i,1),2)));
            simDenom = simDenom + (neigh1(i,2));
        end
    end
    sim= simNumer/simDenom ;
    new_r = userRating(user,2) + sim;
%     if A(1682*(user-1) + item,3) ==0
%         A(1682*(user-1) + item,3) = new_r;
%     end
    
%Item Based Collaborative Filtering
    
temp = 0;
n = 1;
count =1; 
while n <= 100000;
    i = 0;
    sumOfRating2 = 0;
    sumOfRatingSqr2 = 0;
    temp = sortedItems(n + i,2);
    while (n + i) <=100000 && temp == sortedItems(n+i,2)
        sumOfRating2 = sumOfRating2 + sortedItems(n+i,3);
        sumOfRatingSqr2 = sumOfRatingSqr2 + (sortedItems(n+i,3)*sortedItems(n+i,3));
        i = i + 1;
    end
    % 3d matrix: itemId , avgRating, sum of squares of ratings
    itemRating(count,1) = temp;
    itemRating(count,2) = sumOfRating2/i;
    itemRating(count,3) = sumOfRatingSqr2;
    n = n + i;
    count = count + 1;
end

%Finding similarity between 10th item and all other items 
user = 10;
item = 10;
Neighborhood = 5;
j=1;
sum2 = 0;
r = 1;
    while j<=1682
        % if rating of item for j != 0 
        if A((1682*(user-1)) + j,3)~= 0
            if j ~= item
                for k = 1:943
                    X = (1682*(k-1)) + item;
                    Y = (1682*(k-1)) + j;
                    sum2 = sum2 + (A(X,3)*A(Y,3));
                end
                similarityValue2 = sum2/((itemRating(item,3)^(0.5))*(itemRating(j,3)^(0.5)));
                similarity2(r,1) = item;
                similarity2(r,2) = j;
                similarity2(r,3) = similarityValue2;
                similarity2(r,4) = A((1682*(user-1)) + j,3);
                r = r+1;
                sum2 = 0;
                k=1;
            end
        end
        j=j+1;
    end
    sortedSimilarItems = sortrows(similarity2,3);
    simNumer2 = 0;
    simDenom2 = 0;
    for i=1:Neighborhood
        if r-i > 0
            neigh2(i,1) = sortedSimilarItems(r-i,2);
            neigh2(i,2) = sortedSimilarItems(r-i,3);
            simNumer2 = simNumer2 + (neigh2(i,2)*(sortedSimilarItems(r-i,4)- itemRating(neigh2(i,1),2)));
            simDenom2 = simDenom2 + (neigh2(i,2));
        end
    end
    sim2= simNumer2/simDenom2;
    new_item_r = itemRating(item,2) + sim2;
   % A(1682*(user-1) + item,3) = itemRating(item,2) + sim2;
    
    
    
    
    