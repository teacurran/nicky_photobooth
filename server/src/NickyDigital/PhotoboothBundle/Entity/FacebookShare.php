<?php

namespace NickyDigital\PhotoboothBundle\Entity;

use Doctrine\ORM\Mapping as ORM;
use Gedmo\Mapping\Annotation as Gedmo;

/**
 * FacebookShares
 *
 * @ORM\Table()
 * @ORM\Entity
 */
class FacebookShare
{
    /**
     * @var integer
     *
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    private $id;

	/**
	 * @ORM\Column(type="string", length=200)
	 */
	protected $email;

	/**
	 * @ORM\ManyToOne(targetEntity="Photo", inversedBy="facebookShares")
	 */
	private $photo;

	/**
	 * @ORM\Column(type="string", length=200)
	 */
	protected $oauthCode;

	/**
	 * @ORM\Column(type="string", length=200)
	 */
	protected $oauthToken;

	// TODO: figure out why Timestampable isn't populating
	/**
	 * @var created $created
	 *
	 * @Gedmo\Timestampable(on="create")
	 * @ORM\Column(type="datetime", nullable=true)
	 */
	protected $created;

	// TODO: figure out why Timestampable isn't populating
	/**
	 * @var dateSent $updated
	 *
	 * @ORM\Column(type="datetime", nullable=true)
	 */
	protected $dateSent;

	/**
	 * @ORM\Column(type="text")
	 */
	protected $body;

	public function setBody($body)
	{
		$this->body = $body;
	}

	public function getBody()
	{
		return $this->body;
	}

	public function setCreated($created)
	{
		$this->created = $created;
	}

	public function getCreated()
	{
		return $this->created;
	}

	public function setDateSent($dateSent)
	{
		$this->dateSent = $dateSent;
	}

	public function getDateSent()
	{
		return $this->dateSent;
	}

	public function setEmail($email)
	{
		$this->email = $email;
	}

	public function getEmail()
	{
		return $this->email;
	}

	public function setId($id)
	{
		$this->id = $id;
	}

	public function getId()
	{
		return $this->id;
	}

	public function setOauthCode($oauthCode)
	{
		$this->oauthCode = $oauthCode;
	}

	public function getOauthCode()
	{
		return $this->oauthCode;
	}

	public function setOauthToken($oauthToken)
	{
		$this->oauthToken = $oauthToken;
	}

	public function getOauthToken()
	{
		return $this->oauthToken;
	}

	public function setPhoto($photo)
	{
		$this->photo = $photo;
	}

	public function getPhoto()
	{
		return $this->photo;
	}

}
