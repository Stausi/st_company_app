import  './Post.css'
import { imageUrl, PostIF } from '../App';

interface Props {
    post: PostIF;
    index: number;
}

const Post: React.FC<Props> = ({ post, index }) => {
    async function DeletePost() {
        await fetchNui("deletePost", { job: index })
    };

    return (
        <div className="post-container">
            <div className="post-title">
                <img src={imageUrl + '/icons/' + post.icon + '.png'} alt={post.name}/>
                <h3>{ post.title }</h3>
            </div>
            <div className="post-image">
                <img src={ post.image } alt={post.name} />
            </div>
            <div className="post-message">
                <p>{ post.message }</p>
            </div>
            { post.isAdmin &&
                <div className="post-delete">
                    <button onClick={() => DeletePost()}><i className="fa-solid fa-xmark"></i></button>
                </div>
            }
        </div>
    );
}

export default Post;