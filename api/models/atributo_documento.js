/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('atributo_documento', {
		id_atributo_documento: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_atributo_documento::regclass)",
			primaryKey: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: false
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		v_string: {
			type: DataTypes.STRING,
			allowNull: true
		},
		v_int: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		v_date: {
			type: DataTypes.DATE,
			allowNull: true
		},
		v_float: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		v_boolean: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		fk_documento_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'documento',
				key: 'id_documento'
			}
		}
	}, {
		tableName: 'atributo_documento',
		timestamps: false
	});
};
