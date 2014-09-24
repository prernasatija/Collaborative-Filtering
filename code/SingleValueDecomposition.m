U = load('u.data');
importdata('Hw4Ques1.m');
sortedMovies = sortrows(U,2);
Movies = [64 127 187 56 177 178 318 357 182 69];
Movies = transpose(Movies);

UserItem = [sortedMovies(sortedMovies(:,2)==64,1:3);sortedMovies(sortedMovies(:,2)==127,1:3); sortedMovies(sortedMovies(:,2)==187,1:3);
                  sortedMovies(sortedMovies(:,2)==56,1:3);sortedMovies(sortedMovies(:,2)==177,1:3);sortedMovies(sortedMovies(:,2)==178,1:3);
                  sortedMovies(sortedMovies(:,2)==318,1:3);sortedMovies(sortedMovies(:,2)==357,1:3);sortedMovies(sortedMovies(:,2)==182,1:3);
                  sortedMovies(sortedMovies(:,2)==69,1:3)];
              sortedBasedOnUsers = sortrows(UserItem,1);
              sortedBasedOnMovies = sortrows(UserItem,2);
UniqueUsers =  unique(U(:,1));
UniqueMovies = unique(Movies(:,1));
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

i=1;
while i <= 100000
    user = sortedUsers(i, 1);
    item = sortedUsers(i, 2);
    %rating = sortedUsers(i, 3)
    if user == 1
        j=1;
        while j <= 1682
            if A(j,1) == user && A(j,2) == sortedUsers(i,2)
                A(j,3) = sortedUsers(i,3);
            else
                A(j,3) = A(j,3);
            end
            j = j+1;
        end
    else
        j = (user - 1)*1682 + 1;
        while j <= user*1682
            if A(j,1) == user && A(j,2) == sortedUsers(i,2)
               A(j,3) = sortedUsers(i, 3);
            else
                A(j,3) = A(j,3);
            end
            j = j+1;
        end
    end
    i = i+1;
end

for i = 1:943
    for j = 1:10
        if A(1682*(i-1) + Movies(j, 1), 3) == 0
            sol(i, j) = -1;
        else
            sol(i, j) = A(1682*(i-1) + Movies(j, 1), 3);
        end
    end
end
 
[U,S,V] = svd(sol);
Vt = transpose(V);

% Rank-2 approximation
k=2;

Uk = U(:,1:2);
Vtk = Vt(1:2,:);
Sk = S(1:2,1:2);

Vtka = Vtk(1,:);
Vtkb = Vtk(2,:);
plot(Vtka(1,1),Vtkb(1,1),Vtka(1,2),Vtkb(1,2),Vtka(1,3),Vtkb(1,3),Vtka(1,4),Vtkb(1,4),Vtka(1,5),Vtkb(1,5),Vtka(1,6),Vtkb(1,6),Vtka(1,7),Vtkb(1,7),Vtka(1,8),Vtkb(1,8),Vtka(1,9),Vtkb(1,9),Vtka(1,10),Vtkb(1,10));

% Question 2 part b-1

sol(269,2) = -1;

%Finding user based rating between 269th user and all other users 
user = 269;
item = 127;
Neighborhood = 5;
j=1;
sum = 0;
r = 1;
    while j<=943
        % if rating of item for j != 0 
        if sol(j,2)~=0
            for k = 1:10
                sum = sum + (sol(user,k)*sol(j,k));
            end
            similarityValue = sum/((userRating(user,3)^(0.5))*(userRating(j,3)^(0.5)));
            similarity1(r,1) = user;
            similarity1(r,2) = j;
            similarity1(r,3) = similarityValue;
            similarity1(r,4) = sol(j,2);
            r = r+1;
            sum = 0;
            k=1;
        end
        j=j+1;
    end
    sortedSimilarUsers = sortrows(similarity1,3);
    simNumer_u = 0;
    simDenom_u = 0;
    for i=1:Neighborhood
        if r-i > 0
            neigh1(i,1) = sortedSimilarUsers(r-i,2);
            neigh1(i,2) = sortedSimilarUsers(r-i,3);
            simNumer_u = simNumer_u + (neigh1(i,2)*(sortedSimilarUsers(r-i,4)- userRating(neigh1(i,1),2)));
            simDenom_u= simDenom_u + (neigh1(i,2));
        end
    end
    sim_u= simNumer_u/simDenom_u;
    user_based_rating = userRating(user,2) + sim_u;
    
%Finding item based rating between 10th item and all other items 
%Item Based Collaborative Filtering

temp = 0;
n = 1;
count =1; 
while n <= 2670;
    i = 0;
    sumOfRating2 = 0;
    sumOfRatingSqr2 = 0;
    temp = sortedBasedOnMovies(n+i,2);
    while (n + i) <=2670 && temp == sortedBasedOnMovies(n+i,2)
        sumOfRating2 = sumOfRating2 + sortedBasedOnMovies(n+i,3);
        sumOfRatingSqr2 = sumOfRatingSqr2 + (sortedBasedOnMovies(n+i,3)*sortedBasedOnMovies(n+i,3));
        i = i + 1;
    end
    % 3d matrix: itemId , avgRating, sum of squares of ratings
    itemRating2(count,1) = temp;
    itemRating2(count,2) = sumOfRating2/i;
    itemRating2(count,3) = sumOfRatingSqr2;
    n = n + i;
    count = count + 1;
end
for i=1:10
    if itemRating2(i,1) == item
        index1 = i;
    end
end
for i=1:10
    if Movies(i,1) == item
        index2 = i;
    end
end
m=1;
sum2 = 0;
r = 1;
    while m<=10
        % if rating of item for j != 0 
        if sol(user,m)~= -1
            if m ~= index2
                for k= 1:943
                    sum2 = sum2 + (sol(k,index2)*sol(k,m));
                end
                similarityValue3 = sum2/((itemRating2(index1,3)^(0.5))*(itemRating2(m,3)^(0.5)));
                similarity3(r,1) = item;
                similarity3(r,2) = Movies(m,1);
                similarity3(r,3) = similarityValue3;
                similarity3(r,4) = sol(user,m);
                r = r+1;
                sum2 = 0;
            end
        end
        m=m+1;
    end
    sortedSimilarMovies = sortrows(similarity3,3);
    simNumer_i = 0;
    simDenom_i = 0;
    for i=1:Neighborhood
        if r-i > 0
            neigh3(i,1) = sortedSimilarMovies(r-i,2);
            neigh3(i,2) = sortedSimilarMovies(r-i,3);
            for n=1:10
                if itemRating2(n,1) == neigh3(i,1)
                    index3 = n;
                end
            end
            simNumer_i = simNumer_i + (neigh3(i,2)*(sortedSimilarMovies(r-i,4)- itemRating2(index3,2)));
            simDenom_i = simDenom_i + (neigh3(i,2));
        end
    end
    sim_i= simNumer_i/simDenom_i;
    item_based_rating = itemRating2(index1,2) + sim_i;
    
   
%Question 2 part b-2 
sol_k = Uk * Sk * Vtk; 
q=1;
sum = 0;
r = 1;
    while q<=943
        % if rating of item for j != 0 
        if sol_k(q,2)~=-1
            for k = 1:10
                sum = sum + (sol_k(user,k)*sol_k(q,k));
            end
            similarityValue4 = sum/((userRating(user,3)^(0.5))*(userRating(q,3)^(0.5)));
            similarity4(r,1) = user;
            similarity4(r,2) = q;
            similarity4(r,3) = similarityValue4;
            similarity4(r,4) = sol_k(q,2);
            r = r+1;
            sum = 0;
            k=1;
        end
        q=q+1;
    end
    % Top similiar users for user 269
    sortedSimilarUsers2 = sortrows(similarity4,3);
    for i=1:Neighborhood
        if r-i > 0
            neigh5(i,1) = sortedSimilarUsers2(r-i,2);
            neigh5(i,2) = sortedSimilarUsers2(r-i,3);
        end
    end    
    % Ques 2 part b-2
    % User Based Filtering for similarities on sol_k
    
    sortedSimilarUsers2 = sortrows(similarity4,3);
    simNumer_u_10 = 0;
    simDenom_u_10 = 0;
    for i=1:Neighborhood
        if r-i > 0
            neigh5(i,1) = sortedSimilarUsers2(r-i,2);
            neigh5(i,2) = sortedSimilarUsers2(r-i,3);
            simNumer_u_10 = simNumer_u_10 + (neigh5(i,2)*(A(1682*(neigh5(i,1) - 1)+item,3)- userRating(neigh5(i,1),2)));
            simDenom_u_10= simDenom_u_10 + (neigh5(i,2));
        end
    end
    sim_u_10= simNumer_u_10/simDenom_u_10;
    user_based_rating_svd = userRating(user,2) + sim_u_10;
    
    % Top similar items for item 127
    
m=1;
sum2 = 0;
r = 1;
    while m<=10
        % if rating of item for j != 0 
        if sol_k(user,m)~= -1
            if m ~= index2
                for k= 1:943
                    sum2 = sum2 + (sol_k(k,index2)*sol_k(k,m));
                end
                similarityValue6 = sum2/((itemRating2(index1,3)^(0.5))*(itemRating2(m,3)^(0.5)));
                similarity6(r,1) = item;
                similarity6(r,2) = Movies(m,1);
                similarity6(r,3) = similarityValue6;
                similarity6(r,4) = sol_k(user,m);
                r = r+1;
                sum2 = 0;
            end
        end
        m=m+1;
    end
    sortedSimilarMovies2 = sortrows(similarity6,3);
    for i=1:Neighborhood
        if r-i > 0
            neigh6(i,1) = sortedSimilarMovies2(r-i,2);
            neigh6(i,2) = sortedSimilarMovies2(r-i,3);
        end
    end
    %Question 2 part b-2
    
    %Item based Filtering for similarities based on sol_k
    r = 10;
    sortedSimilarMovies8 = sortrows(similarity6,3);
    simNumer_i_6 = 0;
    simDenom_i_6 = 0;
    for i=1:Neighborhood
        if r-i > 0
            neigh8(i,1) = sortedSimilarMovies8(r-i,2);
            neigh8(i,2) = sortedSimilarMovies8(r-i,3);
            for n=1:10
                if itemRating2(n,1) == neigh8(i,1)
                    index3 = n;
                end
            end
            simNumer_i_6 = simNumer_i_6 + (neigh8(i,2)*(A(1682*(user - 1) + neigh8(i,1), 3) - itemRating2(index3,2)));
            simDenom_i_6 = simDenom_i_6 + (neigh8(i,2));
        end
    end
    sim_i_6= simNumer_i_6/simDenom_i_6;
    item_based_rating_3 = itemRating2(index1,2) + sim_i_6;
    
    