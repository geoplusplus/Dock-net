function  Ijitter  = ColorJitterPCA( I,mu,sigma )

%do color jitter using pca
%mu: mu of normal rand used in permutation
%sigma: sigma of normal rand used in permutation
%out
I=single(I);
w=size(I,2);
h=size(I,1);
%rgb components
r=I(:,:,1);
g=I(:,:,2);
b=I(:,:,3);

r=reshape(r,1,[]);
g=reshape(g,1,[]);
b=reshape(b,1,[]);

%X is a reshaped data whose dimension(col) is 3,and rows are the number of
%pixels in I
X=[r',g',b'];



% Make sure data is zero mean
mapping.mean = mean(X, 1);
X = bsxfun(@minus, X, mapping.mean);

% Compute covariance matrix

C = cov(X);

% Perform eigendecomposition of C
C(isnan(C)) = 0;
C(isinf(C)) = 0;
[M, lambda] = eig(C);

% Sort eigenvectors in descending order
[lambda, ind] = sort(diag(lambda), 'descend');

%get eigenvectors ,p1 is the eigenvector with the largest eigenvalue,p3 is
%the smallest
p1=M(:,ind(1));
p2=M(:,ind(2));
p3=M(:,ind(3));


%add some permulation to each pixel (Krizhevsky 2012) 
perm=normrnd(mu,sigma,[3,1]);
m1=perm.*lambda;

tmp1=[p1,p2,p3]*m1;
Xafterperm = bsxfun(@plus, X, tmp1');

Xafterplusmean=bsxfun(@plus, Xafterperm, mapping.mean);

Ijitter=reshape(Xafterplusmean,[h,w,3]);


% figure;subplot(1,2,1);imshow(I/255);
% subplot(1,2,2);imshow(Ijitter/255);


end

