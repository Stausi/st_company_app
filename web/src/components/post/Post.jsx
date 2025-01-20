import  './Post.css'

const Post = (props) => {
    const { fetchNui } = window;
    const company = props.company;

    async function DeletePost() {
        await fetchNui("deletePost", { job: props.index })
    };

    return (
        <div className="post-container">
            <div className="post-title">
                <img src={process.env.PUBLIC_URL + '/icons/' + company.icon + '.png'} alt={company.name}/>
                <h3>{ company.title }</h3>
            </div>
            <div className="post-image">
                <img src={ company.image } alt={company.name} />
            </div>
            <div className="post-message">
                <p>{ company.message }</p>
            </div>
            { company.isAdmin &&
                <div className="post-delete">
                    <button onClick={() => DeletePost()}><i className="fa-solid fa-xmark"></i></button>
                </div>
            }
        </div>
    );
}

export default Post;